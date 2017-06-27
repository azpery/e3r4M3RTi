//
//  HelpButton.swift
//  OremiaMobile2
//
//  Created by Zumatec on 06/12/2015.
//  Copyright © 2015 Zumatec. All rights reserved.
//

import UIKit

class HelpButton: UIViewController {
    var yPosition: CGFloat = 0.0
    var xPosition: CGFloat = 50
    let height:CGFloat = 70
    let width:CGFloat = 70
    var baseView = UIView()
    var base = SCLButton()
    var caller:UIViewController?
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    required internal init() {
        super.init(nibName:nil, bundle:nil)
        
    }
    override func viewDidLoad(){
        NotificationCenter.default.addObserver(self, selector: #selector(HelpButton.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        self.updateView()
        
    }
    internal func updateView(){
        xPosition = UIScreen.main.bounds.width - width - 10
        yPosition = UIScreen.main.bounds.height - height - 10
        view.frame = CGRect(x: xPosition, y:yPosition , width: width, height: height)
        view.backgroundColor = ToolBox.UIColorFromRGB(0xe5793b)
        view.layer.cornerRadius = view.frame.size.height / 2
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = view.frame.size.height / 2
        base.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
    }
    internal func showButton(_ caller:UIViewController){
        //let rv = UIApplication.sharedApplication().keyWindow! as UIWindow
        caller.view.addSubview(view)
        base.target = self
        base.selector = #selector(HelpButton.triggerPopOver)
        self.caller = caller
        
        //        base.layer.masksToBounds = true
        base.addTarget(self, action: #selector(HelpButton.triggerPopOver), for: UIControlEvents.touchUpInside)
        base.setFAIcon(FAType.faMedkit,  forState: UIControlState())
//        base.tintColor = UIColor.whiteColor()
        base.isEnabled = true
        base.isUserInteractionEnabled = true
        base.layer.masksToBounds = true
        view.addSubview(base)
    }
    func triggerPopOver(){
        let popoverContent = (caller!.storyboard?.instantiateViewController(withIdentifier: "Help"))! as UIViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        caller!.present(nav, animated: true, completion: nil)
    }
    func rotated(){
        self.updateView()
    }

}
