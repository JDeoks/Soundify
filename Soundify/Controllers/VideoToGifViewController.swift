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
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var exportButton: UIButton!
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - \(#function)")
        
        action()
        presentImagePicker(mode: [ UTType.movie.identifier ])
    }
    
    func action() {
        exportButton.rx.tap
            .subscribe { _ in
//                <#code#>
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
        videoURLToGif(fromVideoAtURL: videoUrl)
    }
    
    
    // TODO: - Gif 생성코드
    func videoURLToGif(fromVideoAtURL url: URL) {
        print("\(type(of: self)) - \(#function)")
        
        /// AVURLAsset을 사용하여 동영상 URL에서 생성한 AVAsset
        let asset = AVURLAsset(url: url)
        /// 동영상의 길이(초)
        let duration = asset.duration.seconds
        /// 초당 프레임 수
        let frameRate: Int = 5
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
        let resultingFilename = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "videoToGIF.gif")
        let resultingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(resultingFilename)
        let destination = CGImageDestinationCreateWithURL(resultingFileURL as CFURL, kUTTypeGIF, totalFrames, nil)!
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        var framesProcessed = 0
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = CMTime(seconds: 0.05, preferredTimescale: 600)
        generator.requestedTimeToleranceAfter = CMTime(seconds: 0.05, preferredTimescale: 600)
        
        generator.generateCGImagesAsynchronously(forTimes: timeValues) { (requestedTime, resultingImage, actualTime, result, error) in
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
                                self.shareGIF(fromURL: destinationURL)
                            }
                        } catch {
                            print("GIF 파일을 Documents 디렉토리로 복사하는 데 실패했습니다.")
                        }
                    }
                }
            }
        }
    }
    
    func shareGIF(fromURL url: URL) {
        print("\(type(of: self)) - \(#function)")

            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
    }
}
