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

class VideoToAudioViewController: UIViewController {
    
    var fileName: String = ""
    var videoURL: URL? = nil
    /// 받은 동영상에서 바꾼 m4a
    var convertedAudioURL: URL? = nil
    /// 선택한 확장자로 바꾼 오디오. export 할때 사용
    var exportedAudioURL: URL? = nil
    var selectedFormat: String = "m4a"
    ///
    var documentsDirectory: URL!
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var backwardButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var formatPopupButton: UIButton!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var exportButton: UIButton!
    @IBOutlet var audioProgressUISlider: UISlider!
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - \(#function)")

        initUI()
        initData()
        action()
        
        // 0.1초 마다 updateAudioProgressUISlider 호출해서 audioProgressUISlider.value 업데이트
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioProgressUISlider), userInfo: nil, repeats: true)
        
        presentPicker()
    }
    
    // 타이머에 의해 0.1초 마다 실행되어 audioProgressUISlider.value 업데이트
    @objc func updateAudioProgressUISlider() {
        audioProgressUISlider.value = Float(AudioManager.shared.audioPlayer?.currentTime ?? 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        AudioManager.shared.stopMusic()
//        nameTextField.delegate = nil
//        AudioManager.shared.audioPlayer?.delegate =  nil
    }
    
    // MARK: - initUI
    private func initUI() {
        // nameTextField
        nameTextField.addLeftAndRightPadding(size: 10)
        nameTextField.layer.cornerRadius = 8
        nameTextField.delegate = self

        // formatPopupButton
        formatPopupButton.layer.cornerRadius = 8
        
        // exportButton
        exportButton.layer.cornerRadius = 8
        
        // thumbnailImageView
        thumbnailImageView.layer.cornerRadius = 8
        
        // 팝업버튼 등록
        setPopupButton()
        
        // audioPlayer
//        AudioManager.shared.audioPlayer!.delegate = self
    }
    
    /// 팝업버튼 등록
    func setPopupButton() {
        print("\(type(of: self)) - \(#function)")

        let optionClosure = {(action : UIAction) in
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
        // 뒤로가기
        backButton.rx.tap
            .subscribe { _ in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        // 동영상 선택
        addButton.rx.tap
            .subscribe { _ in
                AudioManager.shared.stopMusic()
                self.presentPicker()
            }
            .disposed(by: disposeBag)
        
        // 재생, 중지
        playButton.rx.tap
            .subscribe { _ in
                // audioOutputURL이 nil인 경우 재생하지 않도록 확인
                if self.convertedAudioURL == nil {
                    print("오디오 파일이 존재하지 않습니다.")
                    return
                }
                self.togglePlayButton()
            }
            .disposed(by: disposeBag)
        
        // 재생바 뒤로가기
        backwardButton.rx.tap
            .subscribe { _ in
                guard let audioPlayer = AudioManager.shared.audioPlayer else {
                    print("audioPlayer 없음")
                    return
                }
                let currentTime = audioPlayer.currentTime - 5.0
                audioPlayer.currentTime = currentTime < 0 ? 0 : currentTime
            }
            .disposed(by: disposeBag)
        
        // 재생바 앞으로 가기
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
    }
    
    private func togglePlayButton() {
        // 재생 여부 토글 후 버튼이미지 변경
        if AudioManager.shared.audioPlayer?.isPlaying == true {
            AudioManager.shared.pauseMusic()
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
            let image = UIImage(systemName: "play.fill", withConfiguration: imageConfig)
            playButton.setImage(image, for: .normal)
        } else {
            AudioManager.shared.playMusic()
            // audioPlayer 음원 길이로 audioProgressUISlider 범위 갱신
            if let audioPlayer = AudioManager.shared.audioPlayer {
                self.audioProgressUISlider.maximumValue = Float(audioPlayer.duration)
            }
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 40)
            let image = UIImage(systemName: "pause.fill", withConfiguration: imageConfig)
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
    
    
    // 슬라이더 이동시 호출
    @IBAction func audioProgressSliderChanged(_ sender: Any) {
        print("\(type(of: self)) - \(#function)")
//
//        if let audioPlayer = AudioManager.shared.audioPlayer {
//            // audioPlayer 음원 길이로 audioProgressUISlider 범위 갱신
//            self.audioProgressUISlider.maximumValue = Float(audioPlayer.duration)
//
//            if audioPlayer.isPlaying {
////                AudioManager.shared.pauseMusic()
//                audioPlayer.currentTime = TimeInterval(audioProgressUISlider.value)
//                print(audioPlayer.currentTime)
////                AudioManager.shared.playMusic()
//            }
//            else {
//                print(audioPlayer.currentTime)
//                audioPlayer.currentTime = TimeInterval(audioProgressUISlider.value)
//            }
//        }
//        else {
//            print("audioPlayer = nil")
//        }
    }

    @IBAction func ExportButtonClicked(_ sender: Any) {
        print("\(type(of: self)) - \(#function)")

        if convertedAudioURL == nil {
            print("공유할 오디오 파일 없음.")
            return
        }
        
        // 오디오 파일을 저장할 URL 생성
        self.exportedAudioURL = documentsDirectory.appendingPathComponent(nameTextField.text!).appendingPathExtension(selectedFormat)
        // 두 확장자 같으면 바로 반환
        if convertedAudioURL == exportedAudioURL {
            presentActivityVC()
            return
        }
        
        // 컨버터 설정&실행
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
        let converter = FormatConverter(inputURL: convertedAudioURL!, outputURL: exportedAudioURL!, options: options)
        DispatchQueue.global().async {
            converter.start { error in
                if let error = error {
                    print("\(#function) - 컨버터 오류", error.localizedDescription)
                    return
                }
                DispatchQueue.main.async{
                    print("\(#function) - 컨버터 성공", self.exportedAudioURL!)
                    self.presentActivityVC()
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        print("\(type(of: self)) - \(#function)")
        
        self.view.endEditing(true)
   }
    
    private func presentActivityVC() {
        print("\(type(of: self)) - \(#function)")

        let activityViewController = UIActivityViewController(activityItems: [self.exportedAudioURL!], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
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
        
        fileName = nameTextField.text!
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
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier){
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
            print("loadFileRepresentation 성공")
            self.videoURLToAudio(videoURL: videoURL)
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
            print("loadFileRepresentation 성공")
            self.videoURLToAudio(videoURL: videoURL)
            self.setThumbnailImage(videoURL: videoURL)
        }
    }
    
    private func videoURLToAudio(videoURL: URL) {
        print("\(type(of: self)) - \(#function) videoURL: \(String(describing: videoURL))")

        // 뷰컨트롤러에 비디오 URL 저장
        self.videoURL = videoURL
        // 비디오로 AVAsset 생성
        let asset = AVAsset(url: videoURL)
        // 오디오 파일을 저장할 URL 생성
        self.convertedAudioURL = documentsDirectory.appendingPathComponent("\(fileName).m4a")
        // 기존 파일 삭제
        deleteFileByURL(url: convertedAudioURL!)
        // 생성한 url에 오디오파일 저장
        asset.saveAudioFileToURL(self.convertedAudioURL!) { (success, error) in
            if success == false {
                print("saveAudioFileToURL 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                return
            }
            print("saveAudioFileToURL 성공 \(String(describing: self.convertedAudioURL)) ")
            // 재생 버튼 활성화 등 원하는 추가 작업 수행
            // 저장 완료 후 오디오 매니저에 음원 등록
            AudioManager.shared.registerAudioByURL(url: self.convertedAudioURL!)
        }
    }
    
    /// url에 있는 파일 삭제
    func deleteFileByURL(url: URL) {
        print("\(type(of: self)) - \(#function)")

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

// MARK: - AVAudioPlayerDelegate
extension VideoToAudioViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("\(type(of: self)) - \(#function)")
        
        // 오디오 재생 종료시 버튼 모양 변경
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50)
        let image = UIImage(systemName: "play.fill", withConfiguration: imageConfig)
        playButton.setImage(image, for: .normal)
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
