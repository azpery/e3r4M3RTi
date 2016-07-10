//
//  SignatureViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 06/07/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class SignatureViewController: UIViewController, DrawableViewDelegate {
    var patient:patients?
    
    var patientb64:String?
    var pratb64:String?
    
    
    var success:((sPrat:String,sPatient:String)->Void)?
    
    @IBOutlet var signatureView: DrawableView!

    @IBOutlet var libelle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var rect = self.navigationController!.view.superview!.bounds;
        rect.size.width = 605;
        rect.size.height = 350;
        self.navigationController!.view.superview!.bounds = rect;
        self.navigationController!.preferredContentSize = CGSizeMake(605, 350);
        self.signatureView.updateConstraints()
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.view.backgroundColor = UIColor.whiteColor()
        if patientb64 == nil && pratb64 != nil{
            self.libelle.text = "Signature du patient"
        }

        // Do any additional setup after loading the view.
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func performSignature(sender: AnyObject) {
        if signatureView.containsSignature && patientb64 == nil && pratb64 == nil{
            let prat = signatureView.getSignatureCropped()
            let data = UIImagePNGRepresentation(prat!)
            pratb64 = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) ?? ""
            let VC1 = self.storyboard!.instantiateViewControllerWithIdentifier("SignatureViewController") as! SignatureViewController
            self.navigationController!.pushViewController(VC1, animated: true)
            VC1.success = success
            VC1.pratb64 = pratb64
            
            // Do something with img
        }else if signatureView.containsSignature && patientb64 == nil && pratb64 != nil{
            let patient = signatureView.getSignatureCropped()
            let data = UIImagePNGRepresentation(patient!)
            patientb64 = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) ?? ""
            
        }
        if success != nil && pratb64 != nil && patientb64 != nil{
            success!(sPrat: pratb64!, sPatient: patientb64!)
            self.dismissViewControllerAnimated(true, completion: {})
        }else if !signatureView.containsSignature && patientb64 == nil && pratb64 != nil || !signatureView.containsSignature && patientb64 == nil && pratb64 == nil{
            ToolBox.shakeIt(self.view)
        }
        
    }
    @IBAction func performCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})

    }
    
    @IBAction func performIgnore(sender: AnyObject) {
        if patientb64 == nil && pratb64 == nil{
            pratb64 = ""
            let VC1 = self.storyboard!.instantiateViewControllerWithIdentifier("SignatureViewController") as! SignatureViewController
            self.navigationController!.pushViewController(VC1, animated: true)
            VC1.success = success
            VC1.pratb64 = pratb64
            // Do something with img
        }else if patientb64 == nil && pratb64 != nil{
            patientb64 = ""
            if signatureView.containsSignature{
                let patient = signatureView.getSignatureCropped()
                let data = UIImagePNGRepresentation(patient!)
                patientb64 = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) ?? ""
            }
        }
        if pratb64 != nil && patientb64 != nil
        {
            if pratb64 != "" || patientb64 != ""{
                success!(sPrat: pratb64!, sPatient: patientb64!)
            }
            self.dismissViewControllerAnimated(true, completion: {})
        }
    }
    func startedSignatureDrawing() {
        // Do something when start drawing
    }
    
    func finishedSignatureDrawing() {
        // Do something else when finished drawing
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
