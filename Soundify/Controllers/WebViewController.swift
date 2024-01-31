//
//  WebViewController.swift
//  Soundify
//
//  Created by JDeoks on 1/31/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private var pageURL: URL? = nil
    
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = pageURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func setData(url: URL) {
        pageURL = url
    }

}
