//
//  SchemaDentaireCollectionViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 07/01/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit


class SchemaDentaireCollectionViewController:  UICollectionViewController{
    let reuseIdentifier = "dent"
    var cellWidth:CGFloat = 0
    var cellHeight:CGFloat = 0
    var patient:patients?
    var chart:Chart?
    override func viewDidLoad() {
        super.viewDidLoad()
        let tb : TabBarViewController = self.tabBarController as! TabBarViewController
        patient = tb.patient!
        self.chart = Chart(idpatient: patient!.id, callback: self.collectionView!.reloadData)
        
        // Register cell classes
//        self.collectionView!.registerClass(DentCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //set cell width and height
        cellWidth = self.view.frame.width/16
        cellHeight = (self.view.frame.height - (self.tabBarController?.tabBar.frame.height)! - (self.navigationController?.navigationBar.frame.height)!)/2
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource


    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 32
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:DentCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DentCollectionViewCell
        var i = indexPath.row
        var image = UIImage()
        cell.contentMode = .ScaleAspectFit
        var layer = (chart?.layerFromIndexPath(i))!
        chart?.imageFromIndexPath(i, layer: layer, imageView: cell.dentLayout)
//        if i <= 7 {
//            i = 18 - i
//            image = UIImage(named: "\(i)")!
//            cell.dentLayout.image = image
//        }else if i > 7 && i <= 15 {
//            i = 3 + i
//            image = UIImage(named: "\(i)")!
//            cell.dentLayout.image = image
//            cell.dentLayout.transform = CGAffineTransformMakeScale(-1, 1)
//        }else if i > 15 && i <= 23 {
//            i = 64 - i
//            image = UIImage(named: "\(i)")!
//            cell.dentLayout.image = image
//        }else if i > 23  {
//            i = 17 + i
//            image = UIImage(named: "\(i)")!
//            cell.dentLayout.image = image
//            cell.dentLayout.transform = CGAffineTransformMakeScale(-1, 1)
//
//        }
//        cell.frame.size  = CGSize(width: cellWidth, height: cellHeight)
//        cell.dentLayout.frame.size = CGSize(width: cellWidth, height: cellHeight)
//        cell.backgroundColor = UIColor.blackColor()

        return cell
    }
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }

    // MARK: UICollectionViewDelegate

    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }


    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }


    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
