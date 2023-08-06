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
    func addLeftAndRightPadding(size: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: self.frame.height))
        
        // Left padding
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
        
        // Right padding
        self.rightView = paddingView
        self.rightViewMode = ViewMode.always
    }
    
}
