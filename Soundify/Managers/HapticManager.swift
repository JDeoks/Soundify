//
//  HapticManager.swift
//  PiCo
//
//  Created by JDeoks on 12/27/23.
//

import Foundation
import UIKit

class HapticManager {
    
    static let shared = HapticManager()

    private let impactFeedbackGenerator: UIImpactFeedbackGenerator

    private init() {
        impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator.prepare()
    }

    func triggerImpact() {
        impactFeedbackGenerator.impactOccurred()
    }
    
}
