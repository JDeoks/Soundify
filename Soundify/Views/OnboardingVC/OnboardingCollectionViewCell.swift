//
//  OnboardingCollectionViewCell.swift
//  PiCo
//
//  Created by JDeoks on 1/9/24.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {

    @IBOutlet var onboardingtitleLabel: UILabel!
    @IBOutlet var onBoardingsubTitleLabel: UILabel!
    @IBOutlet var onboardingDescLabel: UILabel!
    @IBOutlet var onboardingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("ViewCell", self.frame.size)
        onboardingDescLabel.isHidden = true
    }

}
