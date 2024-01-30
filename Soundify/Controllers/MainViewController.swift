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
    
    @IBOutlet var settingButton: UIButton!
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
        
        // TODO: - 구현
        videoToGifViewButton.isHidden = true
    }
    
    private func initData() {
        ConfigManager.shared.fetchRemoteConfig()
    }
    
    private func action() {
        // Video -> Audio
        videoToAudioViewButton.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                let v2a = self.storyboard?.instantiateViewController(identifier: "Video2AudioViewController") as! VideoToAudioViewController
                self.navigationController?.pushViewController(v2a, animated: true)
            }
            .disposed(by: disposeBag)
        
        // Video -> Gif
        videoToGifViewButton.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                let v2a = self.storyboard?.instantiateViewController(identifier: "Video2AudioViewController") as! VideoToAudioViewController
                self.navigationController?.pushViewController(v2a, animated: true)
            }
            .disposed(by: disposeBag)
        
        settingButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                let settingsVC = self.storyboard?.instantiateViewController(identifier: "SettingsViewController") as! SettingsViewController
                self.navigationController?.pushViewController(settingsVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        ConfigManager.shared.fetchRemoteConfigDone
            .subscribe { _ in
                print("fetchRemoteConfigDone")
                // 최소버전
                if ConfigManager.shared.isMinimumVersionSatisfied() == false {
                    DispatchQueue.main.async {
                        self.showUpdateRequired()
                    }
                    return
                }
                // 점검 메시지
                if !ConfigManager.shared.getMaintenanceStateFromLocal().isEmpty {
                    DispatchQueue.main.async {
                        self.showNoticeAlert(message: ConfigManager.shared.getMaintenanceStateFromLocal())
                    }
                    return
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Alert
    func showUpdateRequired() {
        print("\(type(of: self)) - \(#function)")
        
        let sheet = UIAlertController(title: "Update Required", message: "Please update to the latest version for an enhanced experience.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.showUpdateRequired()
            self.openAppStore(appId: "6461084209")
        })
        sheet.addAction(okAction)
        present(sheet, animated: true)
    }
    
    func openAppStore(appId: String) {
        let url = "itms-apps://itunes.apple.com/app/" + appId;
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
