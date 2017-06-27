//
//  CalendrierDefautTableViewCell.swift
//  OremiaMobile2
//
//  Created by Zumatec on 10/02/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class CalendrierDefautTableViewCell: UITableViewCell {

    @IBOutlet var calendrierLabel: UILabel!
    @IBOutlet var rightArrow: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rightArrow.setFAIcon(FAType.faArrowRight, iconSize: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
