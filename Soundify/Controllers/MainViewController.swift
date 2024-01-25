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
import Firebase

class MainViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var videoToAudioViewButton: UIView!
    @IBOutlet var videoToGifViewButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
          AnalyticsParameterItemID: "id-\(title!)",
          AnalyticsParameterItemName: title!,
          AnalyticsParameterContentType: "cont",
        ])
        
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
