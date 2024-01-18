//
//  MainViewController.swift
//  Soundify
//
//  Created by 서정덕 on 2023/08/05.
//

import UIKit
import PhotosUI
import AVKit
import RxSwift
import RxCocoa
import RxGesture

class MainViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var videoToAudioViewButton: UIView!
    @IBOutlet var videoToGifViewButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Locale.current.identifier)
        print(TimeZone.current.identifier)
        initUI()
        initData()
        action()
        bind()
    }
    
    private func initUI() {
        // navigationController
        self.navigationController?.navigationBar.isHidden = true

        // scrollView
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        
        // videoToAudioViewButton
        videoToAudioViewButton.layer.cornerRadius = 16
        
        // videoToGifViewButton
        videoToGifViewButton.layer.cornerRadius = 12
    }
    
    private func initData() {
        
    }
    
    private func action() {
        // Video -> Audio
        videoToAudioViewButton.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                let v2a = self.storyboard?.instantiateViewController(identifier: "Video2AudioViewController") as! VideoToAudioViewController
                self.navigationController?.pushViewController(v2a, animated: true)
            }
            .disposed(by: disposeBag)
        
        // Video -> Gif
        videoToGifViewButton.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                let v2a = self.storyboard?.instantiateViewController(identifier: "Video2AudioViewController") as! VideoToAudioViewController
                self.navigationController?.pushViewController(v2a, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        
    }

}

//extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    func presentImagePicker(mode: [String]) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.mediaTypes = mode
//        // 사진 라이브러리에서 선택
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true, completion: nil)
//    }
//    
//    // 이미지 피커 컨트롤러에서 이미지나 동영상을 선택한 후 호출되는 델리게이트 메서드
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//        
//        // 선택된 미디어의 유형을 확인
//        if let mediaType = info[.mediaType] as? String,
//           mediaType == UTType.movie.identifier,
//           let videoURL = info[.mediaURL] as? URL {
//            // 선택한 동영상 URL을 사용하여 추가적인 처리를 수행
////            playVideo(with: videoURL)
//        }
//    }
//    
//    func playVideo(with videoURL: URL) {
//        let player = AVPlayer(url: videoURL)
//        let playerVC = AVPlayerViewController()
//        playerVC.player = player
//        present(playerVC, animated: true) {
//            player.play()
//        }
//    }
// 
//}

//extension MainViewController: PHPickerViewControllerDelegate {
//    
//    // https://developer.apple.com/forums/thread/652496
//    /// 이미지 피커 표시
//    func presentPHPicker() {
//        print("\(type(of: self)) - \(#function)")
//
//        // 이미지 피커 구성 설정
//        var config = PHPickerConfiguration()
//        config.filter = .videos
//        // 다중 선택 개수
//        config.selectionLimit = 1
//        let imagePicker = PHPickerViewController(configuration: config)
//        imagePicker.delegate = self
//        present(imagePicker, animated: true, completion: nil)
//    }
//    
//    /// 선택 완료 되면 호출되는 델리게이트 함수
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        print("\(type(of: self)) - \(#function)")
//
//        picker.dismiss(animated: true, completion: nil)
//        // 선택된 비디오 배열에서 첫번째 가져와서 확인
//        guard let provider: NSItemProvider = results.first?.itemProvider else {
//            print("선택한 비디오 없음")
//            return
//        }
//    
//        // 선택된 아이템이 비디오 타입인지 확인
//        if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
//            // 비디오 데이터를 로드
//            provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: [:]) { [self] (videoURL, error) in
//                // 로드한 비디오 데이터를 확인하고 에러가 있는지 확인
//                print("result:", videoURL, error)
//                
//                // 비디오 데이터가 로드되었을 경우 메인 스레드에서 비디오 재생 준비
//                DispatchQueue.main.async {
//                    // 비디오 데이터를 URL로 변환하여 AVPlayer를 생성
//                    if let url = videoURL as? URL {
//                        let player = AVPlayer(url: url)
//                        
//                        // AVPlayer를 사용하는 AVPlayerViewController를 생성
//                        let playerVC = AVPlayerViewController()
//                        playerVC.player = player
//                        
//                        // AVPlayerViewController를 화면에 모달로 표시하여 비디오를 재생
////                        self.present(playerVC, animated: true, completion: nil)
//
//                    }
//                }
//            }
//        }
//    }
//}
