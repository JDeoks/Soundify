//
//  UIViewController+.swift
//  Soundify
//
//  Created by JDeoks on 1/26/24.
//

import Foundation
import UIKit

// MARK: - Alert
extension UIViewController {

    func showNoticeAlert(message: String, isLocked: Bool = true) {
        let sheet = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        if !isLocked {
            sheet.addAction(okAction)
        }
        present(sheet, animated: true)
    }
    
}
