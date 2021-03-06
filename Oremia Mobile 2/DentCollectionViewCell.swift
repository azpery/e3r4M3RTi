//
//  DentCollectionViewCell.swift
//  OremiaMobile2
//
//  Created by Zumatec on 07/01/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class DentCollectionViewCell: UICollectionViewCell {
    @IBOutlet var dentLayout: UIImageView!
    @IBOutlet var dent1Layout: UIImageView!
    var layers = [String]()
    var chart:Chart?
    var indexPath:Int?

    
    @IBOutlet var dent2Layout: UIImageView!
    @IBOutlet var dent3Layout: UIImageView!
    @IBOutlet var dent4Layout: UIImageView!
    @IBOutlet var dent5Layout: UIImageView!
    @IBOutlet var dent6Layout: UIImageView!
    @IBOutlet var dent7Layout: UIImageView!
    @IBOutlet var dent8Layout: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for layer in layers {
            let recipe = UIImageView(frame: self.dentLayout.frame)
            recipe.contentMode = .ScaleAspectFit
            self.clipsToBounds = true
            self.addSubview(recipe)
            self.dentLayout.contentMode = .ScaleAspectFit
            self.dentLayout.clipsToBounds = true
            
            chart?.imageFromIndexPath(indexPath!, layer: layer, imageView: recipe)
        }
    }

}
