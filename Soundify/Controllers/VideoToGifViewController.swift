//
//  Video2GifViewController.swift
//  Soundify
//
//  Created by 서정덕 on 2023/09/18.
//

import UIKit
import AVFoundation
import AVKit
import PhotosUI
import MobileCoreServices
import RxSwift
import RxCocoa

class VideoToGifViewController: UIViewController {
    /// 선택한 비디오 url
    var videoURL: URL? = nil
    
    let disposeBag = DisposeBag()
    
    lazy var loadingView = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var frameRateSegmentControl: UISegmentedControl!
    @IBOutlet var exportButton: UIButton!
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - \(#function)")
        
        initUI()
        initData()
        action()
        presentImagePicker(mode: [ UTType.movie.identifier ])
    }
    
    private func initUI() {
        // nameTextField
        nameTextField.addLeftAndRightPadding(left: 12, right: 0)
        nameTextField.layer.cornerRadius = 8
        nameTextField.delegate = self
        
        // thumbnailImageView
        thumbnailImageView.layer.cornerRadius = 8
        
        // exportButton
        exportButton.layer.cornerRadius = 8
    }
    
    private func initData() {
        // nameTextField
        nameTextField.text = "\(DateManager.shared.getCurrentLocalizedDateTimeString())"
    }
    
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
                self.presentImagePicker(mode: [ UTType.movie.identifier ])
            }
            .disposed(by: disposeBag)

        // Gif 추출
        exportButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                guard let url = self.videoURL else {
                    self.showToast(message: "No video selected", keyboardHeight: 0)
                    return
                }
                self.view.addSubview(self.loadingView)
                self.videoURLToGif(videoURL: url)
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - UIImagePickerController
extension VideoToGifViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentImagePicker(mode: [String]) {
        print("\(type(of: self)) - \(#function)")
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = mode
        imagePicker.videoQuality = .typeHigh
        // 사진 라이브러리에서 선택
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 이미지 피커 컨트롤러에서 이미지나 동영상을 선택한 후 호출되는 델리게이트 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\(type(of: self)) - \(#function)")
        
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
        self.videoURL = videoUrl
        setThumbnailImage(videoURL: videoUrl)
    }
    
    
    // MARK: - Gif 생성
    func videoURLToGif(videoURL url: URL) {
        print("\(type(of: self)) - \(#function)")
        
        /// AVURLAsset을 사용하여 동영상 URL에서 생성한 AVAsset
        let asset = AVURLAsset(url: url)
        /// 동영상의 길이(초)
        let duration = asset.duration.seconds
        /// 초당 프레임 수
        var frameRate: Int = 10
        switch frameRateSegmentControl.selectedSegmentIndex {
        case 0:
            frameRate = 3
        case 1:
            frameRate = 5
        case 2:
            frameRate = 10
        default:
            return
        }
        /// Gif가 가질 전체 프레임 수
        let totalFrames = Int(duration * TimeInterval(frameRate))
        /// 프레임 마다의 시간 간격
        let delayBetweenFrames: TimeInterval = 1.0 / TimeInterval(frameRate)
        /// 각 프레임의 시간 값
        var timeValues: [NSValue] = []
        // timeValues 초기화
        for frameNumber in 0 ..< totalFrames {
            let seconds = TimeInterval(delayBetweenFrames) * TimeInterval(frameNumber)
            let time = CMTime(seconds: seconds, preferredTimescale: Int32(NSEC_PER_SEC))
            timeValues.append(NSValue(time: time))
        }
        /// GIF 속성 설정하는 프로퍼티
        let fileProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                // 무한 반복하도록 설정
                kCGImagePropertyGIFLoopCount as String: 0
            ]
        ]
        ///  GIF 파일의 기본 속성을 설정하는 딕셔너리
        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime: delayBetweenFrames
            ]
        ]
        
        // GIF 파일의 이름 생성
        let resultingFilename = "\(nameTextField.text!).gif"
        let resultingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(resultingFilename)
        deleteFileByURL(url: resultingFileURL)
        let destination = CGImageDestinationCreateWithURL(resultingFileURL as CFURL, kUTTypeGIF, totalFrames, nil)!
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        var framesProcessed = 0
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.requestedTimeToleranceBefore = CMTime(seconds: 0.05, preferredTimescale: 600)
        imageGenerator.requestedTimeToleranceAfter = CMTime(seconds: 0.05, preferredTimescale: 600)
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: timeValues) { (requestedTime, resultingImage, actualTime, result, error) in
            guard let resultingImage = resultingImage else { return }
            
            framesProcessed += 1
            
            CGImageDestinationAddImage(destination, resultingImage, frameProperties as CFDictionary)
            
            if framesProcessed == totalFrames {
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("GIF로 변환 완료! 처리된 프레임 수: \(framesProcessed) • 총 소요 시간: \(timeElapsed) 초.")
                
                let result = CGImageDestinationFinalize(destination)
                print("성공했나요?", result)
                
                if result {
                    print("GIF 파일 저장 완료!")
                    
                    // GIF 파일을 앱의 Documents 디렉토리에 복사합니다.
                    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let destinationURL = documentsDirectory.appendingPathComponent(resultingFilename)
                        
                        do {
                            try FileManager.default.copyItem(at: resultingFileURL, to: destinationURL)
                            print("GIF 파일을 Documents 디렉토리에 복사했습니다.")
                            
                            // 복사한 GIF 파일을 공유합니다.
                            DispatchQueue.main.async {
                                self.exportGif(fromURL: destinationURL)
                                self.loadingView.removeFromSuperview()
                            }
                        } catch {
                            self.showToast(message: "Copied GIF file to Documents directory failed.", keyboardHeight: 0)
                            print("Copied GIF file to Documents directory failed.")
                            DispatchQueue.main.async {
                                self.loadingView.removeFromSuperview()
                            }
                        }
                    }
                }
            }
        }
    }
    
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
    
    func exportGif(fromURL url: URL) {
        print("\(type(of: self)) - \(#function)")

            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UITextField
extension VideoToGifViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("\(type(of: self)) - \(#function)")

        self.view.endEditing(true)
        return true
    }
    
}

// MARK: - 썸네일 이미지 처리

extension VideoToGifViewController {
    
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
