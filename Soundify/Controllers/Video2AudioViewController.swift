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

    var audioOutputURL: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Video2AudioViewController - viewDidLoad")
        
        presentImagePicker(mode: [ UTType.movie.identifier ])
//        let player = AVPlayer(url: videoURL!)
//        let playerVC = AVPlayerViewController()
//        playerVC.player = player
//        present(playerVC, animated: true) {
//            player.play()
//        }
    }
    override func viewDidAppear(_ animated: Bool) {

    }
    

    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func audioPlayButtonClicked(_ sender: Any) {
        print("Video2AudioViewController - audioPlayButtonClicked")
            
        // audioOutputURL이 nil인 경우 재생하지 않도록 확인
        guard let audioURL = audioOutputURL else {
            print("오디오 파일이 존재하지 않습니다.")
            return
        }
        AudioManager.shared.playMusicByURL(url: audioURL)
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
           let videoURL = info[.mediaURL] as? URL {
            // 선택한 동영상 URL을 사용하여 추가적인 처리를 수행
            let asset = AVAsset(url: videoURL)
            // 앱의 Document 디렉토리 경로를 가져옴
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                // 오디오 파일을 저장할 URL 생성
                self.audioOutputURL = documentsDirectory.appendingPathComponent("\(UUID()).m4a")
                // AVAsset에서 오디오 트랙을 분리하고 .m4a 오디오 파일로 저장
                asset.writeAudioTrackToURL(self.audioOutputURL!) { (success, error) in
                    if success {
                        print("오디오 트랙을 .m4a 파일로 저장 완료 \(String(describing: self.audioOutputURL)) ")
                        // 재생 버튼 활성화 등 원하는 추가 작업 수행
                    } else {
                        print("오디오 트랙 저장 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    }
                }
            } else {
                print("Document 디렉토리를 찾을 수 없습니다.")
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
