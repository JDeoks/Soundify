//
//  UITextFieldExtention.swift
//  Soundify
//
//  Created by 서정덕 on 2023/08/07.
//

import Foundation
import UIKit

extension UITextField {
    
    /// 좌우로 size만큼 띄움
    func addLeftAndRightPadding(left: CGFloat, right: CGFloat) {
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.height))
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.height))

        // Left padding
        self.leftView = leftPaddingView
        self.leftViewMode = ViewMode.always
        
        // Right padding
        self.rightView = rightPaddingView
        self.rightViewMode = ViewMode.always
    }
        
}
