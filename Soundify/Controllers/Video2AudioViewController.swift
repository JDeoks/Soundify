//
//  Video2AudioViewController.swift
//  Soundify
//
//  Created by 서정덕 on 2023/08/06.
//

import UIKit
import AVFoundation
import AVKit

class Video2AudioViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var formatPopupButton: UIButton!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var exportButton: UIButton!
    @IBOutlet var audioProgressUISlider: UISlider!
    
    var videoURL: URL? = nil
    var audioOutputURL: URL? = nil
    var documentsDirectory: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Video2AudioViewController - viewDidLoad")
        
        initUI()
        
        // 앱의 Document 디렉토리 경로를 가져옴
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.documentsDirectory = documentsDirectory
        } else {
            print("documentsDirectory 오류")
        }
        // 팝업버튼 등록
        formatPopupButtonClicked()
        // MARK: - delegate
        nameTextField.delegate = self
//        AudioManager.shared.audioPlayer!.delegate = self
        
        // 0.1초 마다 updateAudioProgressUISlider 호출해서 audioProgressUISlider.value 업데이트
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioProgressUISlider), userInfo: nil, repeats: true)
        
        presentImagePicker(mode: [ UTType.movie.identifier ])
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AudioManager.shared.stopMusic()
        nameTextField.delegate = nil
//        AudioManager.shared.audioPlayer?.delegate =  nil
    }
    
    func initUI() {
        nameTextField.addLeftAndRightPadding(size: 10)
        nameTextField.layer.cornerRadius = 8
        formatPopupButton.layer.cornerRadius = 8
        exportButton.layer.cornerRadius = 8
        thumbnailImageView.layer.cornerRadius = 8
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// 팝업버튼 등록
    func formatPopupButtonClicked() {
        let optionClosure = {(action : UIAction) in
            print (action.title)
        }
        formatPopupButton.menu = UIMenu (children : [
            UIAction(title : ".m4a", state : .on, handler: optionClosure),
            UIAction(title : ".mp3", handler: optionClosure),
            UIAction (title : ".wav", handler: optionClosure)
        ])
        formatPopupButton.showsMenuAsPrimaryAction = true
        formatPopupButton.changesSelectionAsPrimaryAction=true
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        AudioManager.shared.stopMusic()
        presentImagePicker(mode: [ UTType.movie.identifier ])
    }
    
    // 슬라이더 이동시 호출
    @IBAction func audioProgressSliderChanged(_ sender: Any) {
        print("Video2AudioViewController - audioProgressSliderChanged")

        if let audioPlayer = AudioManager.shared.audioPlayer {
            // audioPlayer 음원 길이로 audioProgressUISlider 범위 갱신
            self.audioProgressUISlider.maximumValue = Float(audioPlayer.duration)
            
            if audioPlayer.isPlaying {
                AudioManager.shared.pauseMusic()
                audioPlayer.currentTime = TimeInterval(audioProgressUISlider.value)
                print(audioPlayer.currentTime)
                AudioManager.shared.playMusic()
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
    
    @IBAction func audioPlayButtonClicked(_ sender: Any) {
        print("Video2AudioViewController - audioPlayButtonClicked")
        
        // audioOutputURL이 nil인 경우 재생하지 않도록 확인
        guard let audioURL = audioOutputURL else {
            print("오디오 파일이 존재하지 않습니다.")
            return
        }
        
        // 재생 여부 토글 후 버튼이미지 변경
        if AudioManager.shared.audioPlayer?.isPlaying == true {
            AudioManager.shared.pauseMusic()
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 50)
            let image = UIImage(systemName: "play.fill", withConfiguration: imageConfig)
            playButton.setImage(image, for: .normal)
        }
        else {
            AudioManager.shared.playMusic()
            // audioPlayer 음원 길이로 audioProgressUISlider 범위 갱신
            if let audioPlayer = AudioManager.shared.audioPlayer {
                self.audioProgressUISlider.maximumValue = Float(audioPlayer.duration)
            }
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 50)
            let image = UIImage(systemName: "pause.fill", withConfiguration: imageConfig)
            playButton.setImage(image, for: .normal)
        }
            

    }
    
    @IBAction func backwardButtonClicked(_ sender: Any) {
        print("Video2AudioViewController - backwardButtonClicked")

        guard let audioPlayer = AudioManager.shared.audioPlayer else {
            print("audioPlayer 없음")
            return
        }
        let currentTime = audioPlayer.currentTime - 5.0
        if currentTime > 0 {
            audioPlayer.currentTime = currentTime
        } else {
            audioPlayer.currentTime = 0
        }
    }
    
    @IBAction func forwardButtonClicked(_ sender: Any) {
        print("Video2AudioViewController - forwardButtonClicked")

        guard let audioPlayer = AudioManager.shared.audioPlayer else {
            print("audioPlayer 없음")
            return
        }
        let currentTime = audioPlayer.currentTime + 5.0
        if currentTime < audioPlayer.duration {
            audioPlayer.currentTime = currentTime
        }
    }
    
    @IBAction func ExportButtonClicked(_ sender: Any) {
        print("Video2AudioViewController - ExportButtonClicked")
        
        // audioOutputURL이 nil인 경우 공유할 파일이 없으므로 리턴
        if audioOutputURL == nil {
            print("공유할 오디오 파일이 없습니다.")
            return
        }
        
        // 오디오 파일을 저장할 URL 생성
        self.audioOutputURL = documentsDirectory.appendingPathComponent("\(nameTextField.text!).m4a")
        // 중복 삭제
        deleteFileByURL(url: audioOutputURL!)
        
        let asset = AVAsset(url: videoURL!)
        // AVAsset에서 오디오 트랙을 분리하고 .m4a 오디오 파일로 저장
        // TODO: 비동기 처리 잘 안됨
        asset.writeAudioTrackToURL(self.audioOutputURL!) { (success, error) in
            if success {
                print("오디오 트랙을 .m4a 파일로 저장 완료 \(String(describing: self.audioOutputURL)) ")
                // 저장 완료 후 공유 (메인 스레드에서 실행)
                DispatchQueue.main.sync {
                    let activityViewController = UIActivityViewController(activityItems: [self.audioOutputURL!], applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                }

            } else {
                print("오디오 트랙 저장 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
            }
        }
    }
    
    // 타이머에 의해 0.1초 마다 실행되어 audioProgressUISlider.value 업데이트
    @objc func updateAudioProgressUISlider() {
        audioProgressUISlider.value = Float(AudioManager.shared.audioPlayer?.currentTime ?? 0)
    }
    
}

extension Video2AudioViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentImagePicker(mode: [String]) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = mode
        // 동영상 품질 설정 (high, medium, low 중 선택)
//        imagePicker.videoQuality = .typeHigh
        // 사진 라이브러리에서 선택
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 이미지 피커 컨트롤러에서 이미지나 동영상을 선택한 후 호출되는 델리게이트 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // 선택된 미디어의 유형을 확인
        if let mediaType = info[.mediaType] as? String,
           mediaType == UTType.movie.identifier,
           let url = info[.mediaURL] as? URL {
            // 선택한 동영상 URL을 사용하여 추가적인 처리를 수행
            // 뷰컨트롤러에 비디오 URL 저장
            self.videoURL = url
            let asset = AVAsset(url: url)
            // 오디오 파일을 저장할 URL 생성
            self.audioOutputURL = documentsDirectory.appendingPathComponent("\(nameTextField.text!).m4a")
            // 중복 삭제
            deleteFileByURL(url: audioOutputURL!)
            // AVAsset에서 오디오 트랙을 분리하고 .m4a 오디오 파일로 저장
            asset.writeAudioTrackToURL(self.audioOutputURL!) { (success, error) in
                if success {
                    print("오디오 트랙을 .m4a 파일로 저장 완료 \(String(describing: self.audioOutputURL)) ")
                    // 재생 버튼 활성화 등 원하는 추가 작업 수행
                    // 저장 완료 후 오디오 매니저에 음원 등록
                    AudioManager.shared.registerAudioByURL(url: self.audioOutputURL!)
                } else {
                    print("오디오 트랙 저장 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                }
            }
            // 비디오의 썸네일 이미지를 추출하여 이미지 뷰에 표시
            if let thumbnailImage = getThumbnailImage(for: videoURL!) {
                thumbnailImageView.contentMode = .scaleAspectFill
                thumbnailImageView.image = thumbnailImage
            } else {
                print("썸네일 이미지를 추출할 수 없습니다.")
            }
        }
    }
    
    func getThumbnailImage(for videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        // 비디오의 첫 번째 프레임의 이미지를 추출하도록 설정
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.0, preferredTimescale: 600)

        do {
            // 썸네일 이미지를 추출
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            // CGImage를 UIImage로 변환하여 반환
            return UIImage(cgImage: thumbnailCGImage)
        } catch {
            print("썸네일 이미지를 추출하는 동안 오류가 발생했습니다: \\(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteFileByURL(url: URL) {
        print("Video2AudioViewController - deleteDuplicateFile")

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

}

extension Video2AudioViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Video2AudioViewController - audioPlayerDidFinishPlaying")
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 50)
        let image = UIImage(systemName: "play.fill", withConfiguration: imageConfig)
        playButton.setImage(image, for: .normal)
    }
    
}

extension Video2AudioViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Video2AudioViewController - textFieldShouldReturn")
        
        textField.resignFirstResponder()
        return true
    }
    
}
