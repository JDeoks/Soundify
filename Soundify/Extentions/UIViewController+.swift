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

// MARK: - ToastAlert
extension UIViewController {

    func showToast(message : String, keyboardHeight: CGFloat) {

        let toastLabel = UILabel()
        toastLabel.numberOfLines = 2
        toastLabel.backgroundColor = ColorManager.shared.boxGray
        toastLabel.textColor = .black
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 8.7
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)

        let labelSizeCalculator = UILabel()
        labelSizeCalculator.numberOfLines = 2
        labelSizeCalculator.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        labelSizeCalculator.text = message
        labelSizeCalculator.sizeToFit() // 이 부분이 중요
        
        let width = labelSizeCalculator.frame.size.width + 64
        let height = labelSizeCalculator.frame.size.height + 16
        
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(100 + keyboardHeight)
            make.height.equalTo(height)
            make.width.equalTo(width)
        }

        // 애니메이션
        UIView.animate(withDuration: 2, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
