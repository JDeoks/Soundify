//
//  Video2AudioViewController.swift
//  Soundify
//
//  Created by 서정덕 on 2023/08/06.
//

import UIKit
import AVFoundation
import AVKit
import AudioKit
import RxSwift
import RxCocoa
import RxGesture
import RxKeyboard
import PhotosUI
import SnapKit

class VideoToAudioViewController: UIViewController {
    
    let m4a = "m4a"
    let wav = "wav"
    var fileName: String = ""
    var videoURL: URL? = nil
    /// 받은 동영상에서 바꾼 m4a
    var convertedM4AAudioURL: URL? = nil
    var selectedFormat: String = "m4a"
    var documentsDirectory: URL!
    
    let disposeBag = DisposeBag()
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var formatPopupButton: UIButton!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var exportButton: UIButton!
    @IBOutlet var audioProgressUISlider: UISlider!
    @IBOutlet var keyboardToolContainerView: UIView!
    @IBOutlet var hideKeyboardButton: UIButton!
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - \(#function)")

        initUI()
        initData()
        action()
        presentImagePicker(mode: [ UTType.movie.identifier ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        AudioManager.shared.stopMusic()
    }
    
    // MARK: - initUI
    private func initUI() {
        // nameTextField
        nameTextField.addLeftAndRightPadding(left: 12, right: 0)
        nameTextField.layer.cornerRadius = 8
        nameTextField.delegate = self

        // formatPopupButton
        formatPopupButton.layer.cornerRadius = 8
        
        // exportButton
        exportButton.layer.cornerRadius = 8
        
        // thumbnailImageView
        thumbnailImageView.layer.cornerRadius = 8
        
        // audioPlayer
//        AudioManager.shared.audioPlayer!.delegate = self
    }
    
    // MARK: - initData
    private func initData() {
        // documentsDirectory. 앱의 Document 디렉토리 경로를 가져옴
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.documentsDirectory = documentsDirectory
        } else {
            print("documentsDirectory 오류")
        }
        
        // nameTextField
        nameTextField.text = "\(DateManager.shared.getCurrentLocalizedDateTimeString())"
    }
    
    // MARK: - action
    private func action() {
        // 0.1초 마다 updateAudioProgressUISlider 호출해서 audioProgressUISlider.value 업데이트
        Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateAudioProgressUISlider), userInfo: nil, repeats: true)
        
        // 뒤로가기
        backButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 동영상 선택
        addButton.rx.tap
            .subscribe { _ in
                AudioManager.shared.stopMusic()
//                self.presentPicker()
                HapticManager.shared.triggerImpact()
                self.presentImagePicker(mode: [ UTType.movie.identifier ])
            }
            .disposed(by: disposeBag)
        
        // 팝업버튼 등록
        setPopupButton()
        
        // 재생, 중지
        playButton.rx.tap
            .subscribe { _ in
                // audioOutputURL이 nil인 경우 재생하지 않도록 확인
                if self.convertedM4AAudioURL == nil {
                    print("오디오 파일이 존재하지 않습니다.")
                    return
                }
                self.togglePlayButton()
            }
            .disposed(by: disposeBag)
        
        // 재생바 이전으로 가기
        forwardButton.rx.tap
            .subscribe { _ in
                guard let audioPlayer = AudioManager.shared.audioPlayer else {
                    print("audioPlayer 없음")
                    return
                }
                let currentTime = audioPlayer.currentTime - 5.0
                audioPlayer.currentTime = currentTime < 0 ? 0 : currentTime
            }
            .disposed(by: disposeBag)
        
        // 재생바 나중으로 가기
        backwardButton.rx.tap
            .subscribe { _ in
                guard let audioPlayer = AudioManager.shared.audioPlayer else {
                    print("audioPlayer 없음")
                    return
                }
                let currentTime = audioPlayer.currentTime + 5.0
                if currentTime < audioPlayer.duration {
                    audioPlayer.currentTime = currentTime
                }
            }
            .disposed(by: disposeBag)
        
        exportButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.view.addSubview(self.loadingView)
                self.exportAudio()
            }
            .disposed(by: disposeBag)
        
        // 키보드 툴바
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { keyboardVisibleHeight in
                UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: {
                    self.keyboardToolContainerView.snp.updateConstraints { make in
                        if keyboardVisibleHeight == 0 {
                            let containerViewHeight = self.keyboardToolContainerView.frame.height
                            make.bottom.equalToSuperview().inset(-containerViewHeight).priority(1000)
                        } else {
                            make.bottom.equalToSuperview().inset(keyboardVisibleHeight).priority(1000)
                        }
                    }
                    self.view.layoutIfNeeded() // 중요: 레이아웃 즉시 업데이트
                })
            })
            .disposed(by: disposeBag)
        
        // 키보드 툴바 버튼
        hideKeyboardButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    // 타이머에 의해 0.1초 마다 실행되어 audioProgressUISlider.value 업데이트
    @objc func updateAudioProgressUISlider() {
        audioProgressUISlider.value = Float(AudioManager.shared.audioPlayer?.currentTime ?? 0)
    }
    
    /// 팝업버튼 등록
    func setPopupButton() {
        print("\(type(of: self)) - \(#function)")
        
        let optionClosure = {(action : UIAction) in
            AudioManager.shared.stopMusic()

            switch action.title {
            case ".m4a" :
                self.selectedFormat = "m4a"
            case ".mp3" :
                self.selectedFormat = "mp3"
            case ".wav" :
                self.selectedFormat = "wav"
            default:
                self.selectedFormat = "m4a"
            }
            print ("포맷 변경: \(self.selectedFormat)")
        }
        formatPopupButton.menu = UIMenu (children : [
            UIAction(title : ".m4a", state : .on, handler: optionClosure),
//            UIAction(title : ".mp3", handler: optionClosure),
            UIAction (title : ".wav", handler: optionClosure)
        ])
        formatPopupButton.showsMenuAsPrimaryAction = true
        formatPopupButton.changesSelectionAsPrimaryAction = true
    }
    
    private func togglePlayButton() {
        // 재생 여부 토글 후 버튼이미지 변경
        if AudioManager.shared.audioPlayer?.isPlaying == true {
            AudioManager.shared.pauseMusic()
            setPlayButtonImage(playingState: false)
        } else {
            AudioManager.shared.playMusic()
            // audioPlayer 음원 길이로 audioProgressUISlider 범위 갱신
            if let audioPlayer = AudioManager.shared.audioPlayer {
                self.audioProgressUISlider.maximumValue = Float(audioPlayer.duration)
            }
            setPlayButtonImage(playingState: true)
        }
    }
    
    private func setPlayButtonImage(playingState: Bool) {
        if playingState {
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
            let image = UIImage(systemName: "pause.fill", withConfiguration: imageConfig)
            playButton.setImage(image, for: .normal)
        } else {
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
            let image = UIImage(systemName: "play.fill", withConfiguration: imageConfig)
            playButton.setImage(image, for: .normal)
        }
    }
    
    // MARK: - IBAction
    @IBAction func audioProgressSliderTouchUpInside(_ sender: Any) {
        print("\(type(of: self)) - \(#function)")

        if let audioPlayer = AudioManager.shared.audioPlayer {
            // audioPlayer 음원 길이로 audioProgressUISlider 범위 갱신
            self.audioProgressUISlider.maximumValue = Float(audioPlayer.duration)
            
            if audioPlayer.isPlaying {
//                AudioManager.shared.pauseMusic()
                audioPlayer.currentTime = TimeInterval(audioProgressUISlider.value)
                print(audioPlayer.currentTime)
//                AudioManager.shared.playMusic()
            }
            else {
                print(audioPlayer.currentTime)
                audioPlayer.currentTime = TimeInterval(audioProgressUISlider.value)
            }
        }
        else {
            print("audioPlayer = nil")
        }
    }
    
    @IBAction func audioProgressSliderTouchUpOutside(_ sender: Any) {
        print("\(type(of: self)) - \(#function)")

        if let audioPlayer = AudioManager.shared.audioPlayer {
            // audioPlayer 음원 길이로 audioProgressUISlider 범위 갱신
            self.audioProgressUISlider.maximumValue = Float(audioPlayer.duration)
            
            if audioPlayer.isPlaying {
//                AudioManager.shared.pauseMusic()
                audioPlayer.currentTime = TimeInterval(audioProgressUISlider.value)
                print(audioPlayer.currentTime)
//                AudioManager.shared.playMusic()
            }
            else {
                print(audioPlayer.currentTime)
                audioPlayer.currentTime = TimeInterval(audioProgressUISlider.value)
            }
        }
        else {
            print("audioPlayer = nil")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        print("\(type(of: self)) - \(#function)")
        
        self.view.endEditing(true)
   }
    
    // MARK: - bind
    private func bind() {
        
    }
    
    // MARK: - export 관련 로직
    private func presentActivityVC(exportingURL: URL) {
        print("\(type(of: self)) - \(#function)")

        DispatchQueue.main.async {
            self.loadingView.removeFromSuperview()

            let activityViewController = UIActivityViewController(activityItems: [exportingURL], applicationActivities: nil)

            // 아이폰에서 모달,아이패드에서 팝오버
            if let popoverPresentationController = activityViewController.popoverPresentationController {
                popoverPresentationController.sourceView = self.view // 팝오버의 출발점 뷰
                popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // 출발점 위치
                popoverPresentationController.permittedArrowDirections = [] // 화살표 방향
            }

            self.present(activityViewController, animated: true, completion: nil)
        }
    }

    
    private func exportAudio() {
        print("\(type(of: self)) - \(#function)")

        guard let convertedM4AAudioURL = self.convertedM4AAudioURL else {
            showToast(message: "No video selected", keyboardHeight: 0)
            print("convertedM4AAudioURL 없음")
            self.loadingView.removeFromSuperview()
            return
        }
                
        // 다른 형식일 경우
        let exportingAudioURL = documentsDirectory.appendingPathComponent("\(nameTextField.text!)").appendingPathExtension(selectedFormat)
        print("exportingAudioURL:", exportingAudioURL, "\nselectedFormat:", selectedFormat)
        
        // 형식 m4a면 그대로 추출
        if convertedM4AAudioURL == exportingAudioURL {
            print("이름, 확장자 같음. 바로 export")
            presentActivityVC(exportingURL: convertedM4AAudioURL)
            return
        }
        
        // FormatConverter 옵션 설정
        var options = FormatConverter.Options()
        switch selectedFormat {
        case "m4a":
            options.format = .m4a
        case "wav":
            options.format = .wav
        default:
            options.format = .m4a
        }
        options.sampleRate = 48000
        options.bitDepth = 24
        
        // FormatConverter 실행
        let converter = FormatConverter(inputURL: convertedM4AAudioURL, outputURL: exportingAudioURL, options: options)
        DispatchQueue.global().async {
            converter.start { error in
                
                if let error = error {
                    print("exportAudio", error.localizedDescription)
                    self.loadingView.removeFromSuperview()
                    return
                }
                print("\(#function) 성공: \(exportingAudioURL)")
                self.presentActivityVC(exportingURL: exportingAudioURL)
            }
        }
    }
    
}

// MARK: - PHPickerViewController
extension VideoToAudioViewController: PHPickerViewControllerDelegate {
        
    func presentPicker() {
        print("\(type(of: self)) - \(#function)")

        self.view.endEditing(true)
        var config = PHPickerConfiguration()
//        config.selection = .ordered
        config.filter = .videos
        config.selectionLimit = 1
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("\(type(of: self)) - \(#function)")
        
        picker.dismiss(animated: true, completion: nil)
        guard let result = results.first else {
            return
        }
        
        let itemProvider: NSItemProvider = result.itemProvider
        
        // 비디오 타입 체크
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.mpeg4Movie.identifier) {
            // "public.mpeg-4"
            print("type: mpeg4Movie")
            dealWithMpeg4(itemProvider: itemProvider)
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            // "com.apple.quicktime-movie"
            print("type: movie")
            dealWithQuicktimeMovie(itemProvider: itemProvider)
        } else {
            let types = itemProvider.registeredTypeIdentifiers
            print("type: 맞는 타입 없음", types)
        }
    }
    
    // MARK: - 비디오 처리 로직
    private func dealWithMpeg4(itemProvider: NSItemProvider) {
        print("\(type(of: self)) - \(#function)")

        let mpeg4 = UTType.mpeg4Movie.identifier // "com.apple.quicktime-movie"
        // NB we could have a Progress here if we want one
        itemProvider.loadFileRepresentation(forTypeIdentifier: mpeg4) { url, err in
            guard let videoURL = url else {
                print(err!.localizedDescription)
                return
            }
            // 뷰컨트롤러에 비디오 URL 저장
            self.videoURL = videoURL
            print("loadFileRepresentation 성공")
            self.videoURLToAudio(videoURL: videoURL, format: self.m4a)
            self.setThumbnailImage(videoURL: videoURL)
        }
    }
    
    private func dealWithQuicktimeMovie(itemProvider: NSItemProvider) {
        print("\(type(of: self)) - \(#function)")

        let movie = UTType.movie.identifier // "com.apple.quicktime-movie"
        // NB we could have a Progress here if we want one
        itemProvider.loadFileRepresentation(forTypeIdentifier: movie) { url, err in
            guard let videoURL = url else {
                print(err!.localizedDescription)
                return
            }
            self.videoURL = videoURL
            print("loadFileRepresentation 성공")
            self.videoURLToAudio(videoURL: videoURL, format: self.m4a)
            self.setThumbnailImage(videoURL: videoURL)
        }
    }
    
    private func videoURLToAudio(videoURL: URL, format: String) {
        print("\(type(of: self)) - \(#function) videoURL: \(String(describing: videoURL))")

        // 비디오로 AVAsset 생성
        let asset = AVAsset(url: videoURL)
        print("fileName:", fileName)
        // 오디오 파일을 저장할 URL 생성
        self.convertedM4AAudioURL = documentsDirectory.appendingPathComponent("\(fileName).\(format)")
        // 기존 파일 삭제
        deleteFileByURL(url: convertedM4AAudioURL!)
        // 생성한 url에 오디오파일 저장
        asset.saveAudioFileToURL(self.convertedM4AAudioURL!) { (success, error) in
            if success == false {
                print("saveAudioFileToURL 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                return
            }
            print("saveAudioFileToURL 성공 \(String(describing: self.convertedM4AAudioURL)) ")
            // 재생 버튼 활성화 등 원하는 추가 작업 수행
            // 저장 완료 후 오디오 매니저에 음원 등록
            AudioManager.shared.registerAudioByURL(url: self.convertedM4AAudioURL!)
            AudioManager.shared.audioPlayer?.delegate = self
        }
    }
    
    /// url에 있는 파일 삭제
    func deleteFileByURL(url: URL) {
        print("\(type(of: self)) - \(#function) \(url)")

        // 중복 체크해서 이미 있으면 파일 삭제
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                // 파일이 존재하는 경우, 기존 파일 삭제
                try FileManager.default.removeItem(at: url)
                print("기존 파일 삭제 완료.")
            } catch {
                print("기존 파일 삭제 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 썸네일이미지 이미지뷰에 표시
    func setThumbnailImage(videoURL: URL) {
        print("\(type(of: self)) - \(#function) videoURL: \(String(describing: videoURL))")
        getThumbnailImage(for: videoURL) { thumbnailImage in
            DispatchQueue.main.async {
                self.thumbnailImageView.contentMode = .scaleAspectFill
                self.thumbnailImageView.image = thumbnailImage
            }
        }
    }
    
    /// 영상 시작화면 캡쳐해서 썸네일 추출
    func getThumbnailImage(for videoURL: URL, completion: @escaping (UIImage) -> Void) -> Void {
        print("\(type(of: self)) - \(#function) videoURL: \(String(describing: videoURL))")

        let videoAsset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: videoAsset)

        imageGenerator.appliesPreferredTrackTransform = true
        let firstTime = CMTime(value: 0, timescale: 1000)
        let secondTime = CMTime(value: 1, timescale: 1000)

        let times: [NSValue] = [firstTime as NSValue, secondTime as NSValue]
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { _, cgImage, _, _, error in
            guard let cgImage = cgImage else {
                print("generateCGImagesAsynchronously 실패", error!.localizedDescription)
                return
            }
            completion(UIImage(cgImage: cgImage))
        }
    }
    
}

// MARK: - UIImagePickerController
extension VideoToAudioViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentImagePicker(mode: [String]) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = mode
        imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
        // 동영상 품질 설정 (high, medium, low 중 선택)
        //        imagePicker.videoQuality = .typeHigh
        // 사진 라이브러리에서 선택
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 이미지 피커 컨트롤러에서 이미지나 동영상을 선택한 후 호출되는 델리게이트 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\(type(of: self)) - \(#function)")
        
        fileName = nameTextField.text!
        picker.dismiss(animated: true, completion: nil)
        
        // 미디어 타입이 동영상인지 확인
        guard let mediaType = info[.mediaType] as? String else {
            print("미디어 타입 동영상 아님")
            return
        }
        // 미디어 타입이 동영상이 아니면 함수 종료
        guard mediaType == UTType.movie.identifier else {
            print("미디어 타입 동영상 아님")
            return
        }
        // 동영상 URL을 가져올 수 있는지 확인
        guard let videoUrl = info[.mediaURL] as? URL else {
            print("url 추출 실패")
            return
        }
        self.videoURLToAudio(videoURL: videoUrl, format: m4a)
        self.setThumbnailImage(videoURL: videoUrl)
    }
}

// MARK: - AVAudioPlayerDelegate
extension VideoToAudioViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("\(type(of: self)) - \(#function)")
        
        // 오디오 재생 종료시 버튼 모양 변경
        setPlayButtonImage(playingState: false)
    }
}

// MARK: - UITextField
extension VideoToAudioViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("\(type(of: self)) - \(#function)")

        self.view.endEditing(true)
        return true
    }
    
}
