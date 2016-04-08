//
//  PreferenceTableViewCell.swift
//  OremiaMobile2
//
//  Created by Zumatec on 28/01/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class PreferenceTableViewCell: UITableViewCell {

    @IBOutlet var heureDebut: UITextField!
    @IBOutlet var heureFin: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
