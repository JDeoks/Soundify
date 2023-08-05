//
//  ViewController.swift
//  Soundify
//
//  Created by 서정덕 on 2023/08/05.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var video2AudioView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
        let video2AudioTabGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(video2AudioClicked(_:)))
        video2AudioView.addGestureRecognizer(video2AudioTabGesture)
    }
    
    func initUI() {
        video2AudioView.layer.cornerRadius = 16
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func video2AudioClicked(_ gesture: UITapGestureRecognizer) {
        print("ViewController - video2AudioClicked")
        
        let v2a = self.storyboard?.instantiateViewController(identifier: "Video2AudioViewController") as! Video2AudioViewController
        self.navigationController?.pushViewController(v2a, animated: true)
    }
}

