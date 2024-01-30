//
//  ColorManager.swift
//  Soundify
//
//  Created by JDeoks on 1/26/24.
//

import Foundation
import UIKit

class ColorManager {
    
    static let shared = ColorManager()
    private init() { }
    
    let backGroundWhite: UIColor! = UIColor(named: "BackGroundWhite")
    let boxGray: UIColor! = UIColor(named: "BoxGray")
    let keyboardToolBar: UIColor! = UIColor(named: "KeyboardToolBar")
    let keyboardToolBarButton: UIColor! = UIColor(named: "KeyboardToolBarButton")
    let lableBlack: UIColor! = UIColor(named: "LableBlack")
    let nabTabGray: UIColor! = UIColor(named: "NabTabGray")
    let titleWhite: UIColor! = UIColor(named: "TitleWhite") 
}
