//
//  SaisieActesTableViewCell.swift
//  OremiaMobile2
//
//  Created by Zumatec on 28/04/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class SaisieActesTableViewCell: UITableViewCell {
    @IBOutlet var montant: UILabel!
    @IBOutlet var localisation: UILabel!
    @IBOutlet var cotation: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var descriptif: UILabel!
    @IBOutlet var depense: UILabel!
    @IBOutlet var lettre: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
