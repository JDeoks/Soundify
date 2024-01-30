//
//  SettingsViewController.swift
//  Soundify
//
//  Created by JDeoks on 1/31/24.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let menus = [
        ["튜토리얼 보기"],
        ["개인정보 처리방침", "오픈소스 라이센스", "개발자 정보", "버전"]]
    let menuImages = ["person.fill", "book.fill", "star.fill"]
    let urls = [
        "https://jdeoks.notion.site/5cc8688a9432444eaad7a8fdc4e4e38a",
        "https://jdeoks.notion.site/bace573d0a294bdeae4a92464448bcac",
        "https://jdeoks.notion.site/ca304e392e1246abbd51fe0bc37e76bb",
        "https://jdeoks.notion.site/a747b302e36f4c369496e7372768d685",
    ]
    
    @IBOutlet var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
