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
    
    var selectedRow = 1
    
    
    var success:((_ sPrat:String,_ sPatient:String, _ selectedRow:Int)->Void)?
    
    @IBOutlet var signatureView: DrawableView!

    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var skipButton: UIBarButtonItem!
    @IBOutlet var validButton: UIBarButtonItem!
    @IBOutlet var libelle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.setFAIcon(FAType.faClose, iconSize: 22)
        skipButton.setFAIcon(FAType.faStepForward, iconSize: 22)
        validButton.setFAIcon(FAType.faCheck, iconSize: 22)
        self.view.backgroundColor = UIColor.white
        if patientb64 == nil && pratb64 != nil{
            self.libelle.text = "Signature du patient"
        }

        // Do any additional setup after loading the view.
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func performSignature(_ sender: AnyObject) {
        if signatureView.containsSignature && patientb64 == nil && pratb64 == nil{
            let prat = signatureView.getSignatureCropped()
            let data = UIImagePNGRepresentation(prat!)
            pratb64 = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) ?? ""
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "SignatureViewController") as! SignatureViewController
            self.navigationController!.pushViewController(VC1, animated: true)
            VC1.success = success
            VC1.pratb64 = pratb64
            VC1.selectedRow = self.selectedRow
            
        }else if signatureView.containsSignature && patientb64 == nil && pratb64 != nil{
            let patient = signatureView.getSignatureCropped()
            let data = UIImagePNGRepresentation(patient!)
            patientb64 = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) ?? ""
            
        }
        if success != nil && pratb64 != nil && patientb64 != nil{
            success!(pratb64!, patientb64!, self.selectedRow)
            self.dismiss(animated: true, completion: {})
        }else if !signatureView.containsSignature && patientb64 == nil && pratb64 != nil || !signatureView.containsSignature && patientb64 == nil && pratb64 == nil{
            ToolBox.shakeIt(self.view)
        }
        
    }
    @IBAction func performCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})

    }
    
    @IBAction func performIgnore(_ sender: AnyObject) {
        if patientb64 == nil && pratb64 == nil{
            pratb64 = ""
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "SignatureViewController") as! SignatureViewController
            self.navigationController!.pushViewController(VC1, animated: true)
            VC1.success = success
            VC1.pratb64 = pratb64
            // Do something with img
        }else if patientb64 == nil && pratb64 != nil{
            patientb64 = ""
            if signatureView.containsSignature{
                let patient = signatureView.getSignatureCropped()
                let data = UIImagePNGRepresentation(patient!)
                patientb64 = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) ?? ""
            }
        }
        if pratb64 != nil && patientb64 != nil
        {
            if pratb64 != "" || patientb64 != ""{
                success!(pratb64!, patientb64!, self.selectedRow)
            }
            self.dismiss(animated: true, completion: {})
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
