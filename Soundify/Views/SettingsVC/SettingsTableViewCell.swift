//
//  SettingsTableViewCell.swift
//  PiCo
//
//  Created by 서정덕 on 11/24/23.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var menuImageView: UIImageView!
    @IBOutlet var menuLabel: UILabel!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var pleaseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initUI() {
        imageContainerView.layer.cornerRadius = 4
        UIView.animate(withDuration: 2) {
            self.pleaseLabel.alpha = 0
        }
    }
}
