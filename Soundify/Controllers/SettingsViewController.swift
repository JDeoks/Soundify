//
//  SettingsViewController.swift
//  Soundify
//
//  Created by JDeoks on 1/31/24.
//

import UIKit
import StoreKit
import RxSwift
import RxCocoa

class SettingsViewController: UIViewController {
    
    let menus = [
        ["View Tutorial", "Rate the App", "Share the App"],
        ["Privacy Policy", "Open Source Licenses", "Version"]]
    let menuImages = ["book", "star", "square.and.arrow.up"]
    let urls = [
        "https://jdeoks.notion.site/Soundify-Privacy-Policy-137d33c63e29430297010685750c204e?pvs=4",
        "https://jdeoks.notion.site/Soundify-Open-Source-Licenses-d614f7fb105a4a67815c9567515dfd59?pvs=4"
    ]
    
    let disposeBag = DisposeBag()
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        action()
    }
    
    func initUI() {
        // menuTableView
        menuTableView.contentInset.top = 8
        menuTableView.dataSource = self
        menuTableView.delegate = self
        let settingsTableViewCell = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        menuTableView.register(settingsTableViewCell, forCellReuseIdentifier: "SettingsTableViewCell")
    }
    
    func action() {
        backButton.rx.tap
            .subscribe { _ in
                HapticManager.shared.triggerImpact()
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}


// MARK: - UITableView
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        menus.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        cell.menuLabel.text = menus[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            cell.menuImageView.image = UIImage(systemName: menuImages[indexPath.row])
            if indexPath.row == 1 {
                cell.pleaseLabel.text = "please..."
            }
        case 1:
            cell.imageContainerView.isHidden = true
            if indexPath.row == 2 {
                cell.versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            }
            
        default:
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
        case 0:
            return 72
        case 1:
            return 48
        default:
            return 48
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        // 메인
        case 0:
            switch indexPath.row {
            // 온보딩 보기
            case 0:
                HapticManager.shared.triggerImpact()
                let onboardingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
                onboardingVC.modalPresentationStyle = .overFullScreen
                onboardingVC.modalTransitionStyle = .crossDissolve
                self.present(onboardingVC, animated: true)
                return
                
            // 앱 평가하기
            case 1:
                HapticManager.shared.triggerImpact()
//                rateApp()
                guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
                SKStoreReviewController.requestReview(in: scene)
                
            case 2:
                HapticManager.shared.triggerImpact()
                let url = "https://apps.apple.com/kr/app/soundify/id6461084209?l=en-GB"
                if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                    shareURL(url: url)
                }
                
            default:
                return
            }
            
        // 노션 웹뷰
        case 1:
            if urls.indices.contains(indexPath.row) == false {
                return
            }
            guard let url = URL(string: urls[indexPath.row]) else {
                print("url 없음")
                return
            }
            let webVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webVC.setData(url: url)
            self.present(webVC, animated: true)
        default:
            return
        }
    }
    
}

// MARK: - SKStoreProductViewController
extension SettingsViewController: SKStoreProductViewControllerDelegate {
    
    func rateApp() {
        let productVC = SKStoreProductViewController()
        productVC.delegate = self
        let parameters = [
            SKStoreProductParameterITunesItemIdentifier: 6461084209
        ]
        productVC.loadProduct(withParameters: parameters, completionBlock: nil)
        self.present(productVC, animated: true, completion: nil)
    }

}

// MARK: - ShareSheet
extension SettingsViewController {

    private func shareURL(url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        // 아이패드에서 실행될 경우
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}
