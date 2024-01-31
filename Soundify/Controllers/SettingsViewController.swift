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
        ["View Tutorial", "Rate the App"],
        ["Privacy Policy", "Open Source Licenses", "Version"]]
    let menuImages = ["book.fill", "star.fill"]
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
            // 계정 관리
            case 0:
                HapticManager.shared.triggerImpact()
                let onboardingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
                onboardingVC.modalPresentationStyle = .overFullScreen
                onboardingVC.modalTransitionStyle = .crossDissolve
                self.present(onboardingVC, animated: true)
                // TODO: 튜토리얼 VC 추가
                return
                
            case 1:
                HapticManager.shared.triggerImpact()
                rateApp()
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
