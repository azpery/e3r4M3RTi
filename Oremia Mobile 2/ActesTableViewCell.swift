//
//  ActesTableViewCell.swift
//  Oremia Mobile 2
//
//  Created by Zumatec on 22/05/2015.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class ActesTableViewCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var montant: UILabel!
    @IBOutlet weak var descriptif: UILabel!
    @IBOutlet weak var icon: UILabel!
    @IBOutlet weak var noteIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
