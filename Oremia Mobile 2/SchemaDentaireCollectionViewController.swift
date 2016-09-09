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
    var selectedCell:[Int] = []
    var cell:[DentCollectionViewCell] = []
    var indexPath:[NSIndexPath] = []
    var chartLayouts:[Int:[Int:String]] = [0:[0:""]]
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
    }
    
    func loadData(){
        if ToolBox.calcAge(patient?.dateNaissance ?? "03/04/1993") <= 10 {
            self.chart = ChartForChildren(idpatient: patient!.id, callback: self.didReceiveData)
        }else{
            self.chart = Chart(idpatient: patient!.id, callback: self.didReceiveData)
        }
        
        self.collectionView!.reloadData()
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
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation:UIInterfaceOrientation){
        self.loadData()
    }
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if(toInterfaceOrientation.isLandscape){
            self.loadData()
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 32
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell:DentCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DentCollectionViewCell
        let i = indexPath.row
        cell.dentLayout.contentMode = .ScaleAspectFit
        cell.dentLayout.clipsToBounds = true
        let layer = self.chart?.layerFromIndexPath(i) ?? [""]

        cell.dent8Layout.image = UIImage(named: "\(self.chart?.localisationFromIndexPath(i))")
        
        cell = (self.chart?.imagesFromIndexPath(i, layer: layer, cell: cell))!
        
        if(self.isSelected(indexPath.row) != -1){
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.grayColor().CGColor
        }else{
            cell.layer.borderWidth = 0.0
        }
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
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell:DentCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DentCollectionViewCell
        self.toggleSelectedCell(indexPath.row, cell: cell, indexPath: indexPath)
        self.collectionView?.reloadItemsAtIndexPaths([indexPath])
    }
    
    func reloadSelectedCell(){
        
        self.collectionView?.reloadItemsAtIndexPaths(self.indexPath)
        
    }
    
    func addImageToSelectedCell(image:String){
        var i = 0
        for index in self.selectedCell{
            let localisation = self.chart?.localisationFromIndexPath(index) ?? index
            var layers = [String]()
            layers = (self.chart?.layerFromIndexPath(self.indexPath[i].row))!
            if layers.count > 0 {
                layers.append(image)
                self.chart?.setLayerFromIndexPath(self.indexPath[i].row, layers: layers)
            }else {
                self.chart?.chart.append(Chart(idpatient: (self.patient?.id)!, date: ToolBox.getFormatedDateWithSlash(NSDate()), localisation: localisation, layer: image))
            }
            i += 1
        }
        
        
        
    }
    func didReceiveData(){
        dispatch_async(dispatch_get_main_queue(), {
            
            self.collectionView!.reloadData()
            
            if self.actesController?.finished > 1 {
                LoadingOverlay.shared.hideOverlayView()
            } else {
                self.actesController?.finished++
            }
            
        })
    }
    func toggleSelectedCell(index:Int, cell: DentCollectionViewCell, indexPath:NSIndexPath){
        let found = self.isSelected(index)
        if found == -1{
            self.cell.append(cell)
            self.indexPath.append(indexPath)
            self.selectedCell.append(index)
        }else{
            self.selectedCell.removeAtIndex(found)
            self.cell.removeAtIndex(found)
            self.indexPath.removeAtIndex(found)
        }
    }
    
    func isSelected(index:Int)->Int{
        var found = -1
        var cpt = 0
        for i in selectedCell {
            if i == index {
                found = cpt
            }
            cpt += 1
        }
        return found
    }
    
}
