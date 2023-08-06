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
    @IBOutlet var playButtonView: UIButton!
    @IBOutlet var formatPopupButton: UIButton!
    
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
        formatPopupButtonClicked()
        nameTextField.delegate = self
        
        presentImagePicker(mode: [ UTType.movie.identifier ])
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AudioManager.shared.stopMusic()
    }
    
    func initUI() {
        nameTextField.addLeftAndRightPadding(size: 10)
        nameTextField.layer.cornerRadius = 8
        formatPopupButton.layer.cornerRadius = 8
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
        presentImagePicker(mode: [ UTType.movie.identifier ])
    }
    
    @IBAction func audioPlayButtonClicked(_ sender: Any) {
        print("Video2AudioViewController - audioPlayButtonClicked")
            
        // audioOutputURL이 nil인 경우 재생하지 않도록 확인
        guard let audioURL = audioOutputURL else {
            print("오디오 파일이 존재하지 않습니다.")
            return
        }
        // 오디오 재생
        AudioManager.shared.playMusicByURL(url: audioURL)
    }
    
    @IBAction func ExportButtonClicked(_ sender: Any) {
        print("Video2AudioViewController - ExportButtonClicked")
        
        // audioOutputURL이 nil인 경우 공유할 파일이 없으므로 리턴
        guard let audioURL = audioOutputURL else {
            print("공유할 오디오 파일이 없습니다.")
            return
        }
        // 오디오 파일을 저장할 URL 생성
        self.audioOutputURL = documentsDirectory.appendingPathComponent("\(nameTextField.text!).m4a")
        // 중복 삭제
        deleteDuplicateFile(url: audioOutputURL!)
        
        let asset = AVAsset(url: videoURL!)
        // AVAsset에서 오디오 트랙을 분리하고 .m4a 오디오 파일로 저장
        // TODO: 비동기 처리 잘 안됨
        asset.writeAudioTrackToURL(self.audioOutputURL!) { (success, error) in
            if success {
                print("오디오 트랙을 .m4a 파일로 저장 완료 \(String(describing: self.audioOutputURL)) ")
                // 저장 완료 후 공유 (메인 스레드에서 실행)
                DispatchQueue.main.async {
                    let activityViewController = UIActivityViewController(activityItems: [audioURL], applicationActivities: nil)
                    self.present(activityViewController, animated: true, completion: nil)
                }

            } else {
                print("오디오 트랙 저장 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
            }
        }
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
            deleteDuplicateFile(url: audioOutputURL!)
            // AVAsset에서 오디오 트랙을 분리하고 .m4a 오디오 파일로 저장
            asset.writeAudioTrackToURL(self.audioOutputURL!) { (success, error) in
                if success {
                    print("오디오 트랙을 .m4a 파일로 저장 완료 \(String(describing: self.audioOutputURL)) ")
                    // 재생 버튼 활성화 등 원하는 추가 작업 수행
                } else {
                    print("오디오 트랙 저장 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                }
            }

        }
    }
    
    func deleteDuplicateFile(url: URL) {
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
    
    func playVideo(with videoURL: URL) {
        let player = AVPlayer(url: videoURL)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        present(playerVC, animated: true) {
            player.play()
        }
    }
 
}

extension Video2AudioViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
