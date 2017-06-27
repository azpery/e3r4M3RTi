//
//  CalendrierTableViewCell.swift
//  OremiaMobile2
//
//  Created by Zumatec on 08/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class CalendrierTableViewCell: UITableViewCell {
    lazy var circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 7
        return view
    }()
    @IBOutlet var circle: UIView!
    @IBOutlet var calendarLabel: UILabel!
    @IBOutlet var tickIcon: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        selectionStyle = .None
//        
//
//        contentView.addSubview(circleView)
//        
//        let views = [
//            "circleView": circleView,
//            "calendarLabel": calendarLabel,
//            "tickIcon": tickIcon
//        ]
//        
//        let metrics = [
//            "margin": 12,
//            "leftMargin": 6,
//            "lineMargin": 14
//        ]
//        
//        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(leftMargin)-[circleView]-(lineMargin)-[calendarLabel]-[tickIcon]-|", options: [], metrics: metrics, views: views))
//        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(margin)-[calendarLabel]-(margin)-|", options: [], metrics: metrics, views: views))
//
//        contentView.addConstraint(NSLayoutConstraint(item: circleView, attribute: .CenterY, relatedBy: .Equal, toItem: calendarLabel, attribute: .CenterY, multiplier: 1, constant: 0))
//        contentView.addConstraint(NSLayoutConstraint(item: circleView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 14))
//        contentView.addConstraint(NSLayoutConstraint(item: circleView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 14))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
