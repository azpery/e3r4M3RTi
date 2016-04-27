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
    var sourceViewTabBar:UITabBarController?
    var sourceViewNavigationBar:UINavigationController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chart = Chart(idpatient: patient!.id, callback: self.collectionView!.reloadData)
        
        // Register cell classes
//        self.collectionView!.registerClass(DentCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //set cell width and height
        cellWidth = self.view.frame.width/16
        cellHeight = (self.view.frame.height - (sourceViewTabBar?.tabBar.frame.height)! - (sourceViewNavigationBar?.navigationBar.frame.height)!)/2
        
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
        let i = indexPath.row
        cell.dentLayout.contentMode = .ScaleAspectFit
        let layer = (chart?.layerFromIndexPath(i))!
        chart?.imageFromIndexPath(i, layer: layer, imageView: cell.dentLayout)


        return cell
    }
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let row  = chart?.localisationFromIndexPath(indexPath.row)
        if( row >= 16 && row <= 18 || row >= 26 && row <= 28 || row >= 46 && row <= 48 || row >= 36 && row <= 38 ){
            return CGSize(width: cellWidth*(6.7/6), height: cellHeight)
        } else {
            return CGSize(width: cellWidth*(5.3/6), height: cellHeight)

        }
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
