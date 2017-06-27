//
//  SchemaDentaireCollectionViewController.swift
//  OremiaMobile2
//
//  Created by Zumatec on 07/01/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



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
    var indexPath:[IndexPath] = []
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        cellWidth = self.view.bounds.size.width/16
        cellHeight = (self.view.bounds.size.height )/2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        let bottomOffset = CGPoint(x: 0, y: self.collectionView!.contentSize.height - self.collectionView!.bounds.size.height);
        self.collectionView!.contentOffset = bottomOffset
        self.view.layoutIfNeeded()
        cellWidth = self.view.bounds.size.width/16
        cellHeight = (self.view.bounds.size.height )/2
    }
    override func didRotate(from fromInterfaceOrientation:UIInterfaceOrientation){
        self.loadData()
    }
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if(toInterfaceOrientation.isLandscape){
            self.loadData()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 32
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell:DentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DentCollectionViewCell
        let i = indexPath.row
        cell.dentLayout.contentMode = .scaleAspectFit
        cell.dentLayout.clipsToBounds = true
        let layer = self.chart?.layerFromIndexPath(i) ?? [""]

        cell.dent8Layout.image = UIImage(named: "\(String(describing: self.chart?.localisationFromIndexPath(i)))")
        
        cell = (self.chart?.imagesFromIndexPath(i, layer: layer, cell: cell))!
        
        if(self.isSelected(indexPath.row) != -1){
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.gray.cgColor
        }else{
            cell.layer.borderWidth = 0.0
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let row  = chart?.localisationFromIndexPath(indexPath.row)
        if( row >= 16 && row <= 18 || row >= 26 && row <= 28 || row >= 46 && row <= 48 || row >= 36 && row <= 38 ){
            return CGSize(width: cellWidth*(6.7/6), height: cellHeight)
        } else {
            return CGSize(width: cellWidth*(5.3/6), height: cellHeight)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:DentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DentCollectionViewCell
        self.toggleSelectedCell(indexPath.row, cell: cell, indexPath: indexPath)
        self.collectionView?.reloadItems(at: [indexPath])
    }
    
    func reloadSelectedCell(){
        
        self.collectionView?.reloadItems(at: self.indexPath)
        
    }
    
    func addImageToSelectedCell(_ image:String){
        var i = 0
        for index in self.selectedCell{
            let localisation = self.chart?.localisationFromIndexPath(index) ?? index
            var layers = [String]()
            layers = (self.chart?.layerFromIndexPath(self.indexPath[i].row))!
            if layers.count > 0 {
                layers.append(image)
                self.chart?.setLayerFromIndexPath(self.indexPath[i].row, layers: layers)
            }else {
                self.chart?.chart.append(Chart(idpatient: (self.patient?.id)!, date: ToolBox.getFormatedDateWithSlash(Date()), localisation: localisation, layer: image))
            }
            i += 1
        }
        
        
        
    }
    func didReceiveData(){
        DispatchQueue.main.async(execute: {
            
            self.collectionView!.reloadData()
            
            if self.actesController?.finished > 1 {
                LoadingOverlay.shared.hideOverlayView()
            } else {
                self.actesController?.finished = (self.actesController?.finished)! + 1
            }
            
        })
    }
    func toggleSelectedCell(_ index:Int, cell: DentCollectionViewCell, indexPath:IndexPath){
        let found = self.isSelected(index)
        if found == -1{
            self.cell.append(cell)
            self.indexPath.append(indexPath)
            self.selectedCell.append(index)
        }else{
            self.selectedCell.remove(at: found)
            self.cell.remove(at: found)
            self.indexPath.remove(at: found)
        }
    }
    
    func isSelected(_ index:Int)->Int{
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
