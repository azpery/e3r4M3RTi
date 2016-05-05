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
    var actesController:ActesViewController?
    var selectedCell:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chart = Chart(idpatient: patient!.id, callback: self.collectionView!.reloadData)
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        // Register cell classes
//        self.collectionView!.registerClass(DentCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //set cell width and height
        self.view.layoutIfNeeded()
        cellWidth = self.view.bounds.size.width/16
        cellHeight = (self.view.bounds.size.height )/2
        
    }
    override func viewDidAppear(animated: Bool) {
        self.view.layoutIfNeeded()
        cellWidth = self.view.bounds.size.width/16
        cellHeight = (self.view.bounds.size.height )/2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        let bottomOffset = CGPointMake(0, self.collectionView!.contentSize.height - self.collectionView!.bounds.size.height);
        self.collectionView!.contentOffset = bottomOffset
        self.view.layoutIfNeeded()
        cellWidth = self.view.bounds.size.width/16
        cellHeight = (self.view.bounds.size.height )/2
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
//        let recipe = UIImageView(frame: cell.dentLayout.frame)
//        recipe.contentMode = .ScaleAspectFit
//        cell.clipsToBounds = true
//        cell.addSubview(recipe)
        cell.dentLayout.contentMode = .ScaleAspectFit
        cell.dentLayout.clipsToBounds = true
        let layer = (chart?.layerFromIndexPath(i))!
        chart?.imagesFromIndexPath(i, layer: layer, cell: cell)
        cell.setNeedsLayout() //invalidate current layout
        cell.layoutIfNeeded()
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
        let cell:DentCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DentCollectionViewCell
        cell.dentLayout.backgroundColor = UIColor.blueColor()
        print("Dent n°\(chart?.localisationFromIndexPath(indexPath.row)) sélectionné ")
        self.selectedCell = chart?.localisationFromIndexPath(indexPath.row)
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
