//
//  AnimeCollectionViewController.swift
//  Butter
//
//  Created by DjinnGA on 23/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import UIKit

class AnimeCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
        self.title = "Anime"
        ButterAPIManager.sharedInstance.loadAnime({
            self.collectionView?.reloadData()
        })
        
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
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return ButterAPIManager.sharedInstance.cachedAnime.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PTCoverCollectionViewCell
        
        if (indexPath.row == ButterAPIManager.sharedInstance.cachedAnime.count-1) {
            ButterAPIManager.sharedInstance.loadAnime({
                self.collectionView?.reloadData()
            })
        }
        
        // Configure the cell
        if let ite: ButterItem = ButterAPIManager.sharedInstance.cachedAnime[indexPath.row] as ButterItem! {
            if let img: UIImage = ite.getProperty("cover") as? UIImage {
                cell.coverImage.image = img
            } else {
                cell.coverImage.image = UIImage(named: "cover-placeholder")
                /*
                RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String) { image in
                    ButterAPIManager.sharedInstance.cachedAnime[indexPath.row]!.setProperty("cover", val: image)
                    if let cell: PTCoverCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as? PTCoverCollectionViewCell {
                        cell.coverImage.image = image
                        let animation: CATransition = CATransition()
                        animation.duration = 1.0
                        animation.type = kCATransitionFade//"rippleEffect" //pageUnCurl
                        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                        cell.coverImage.layer.addAnimation(animation, forKey:nil)
                    }
                }
                */
            }
            if let title: String = ite.getProperty("title") as? String {
                cell.titleLabel.text = title
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellSize:CGSize = CGSizeMake((self.collectionView!.bounds.width/3)-10, (self.collectionView!.bounds.width/3)+60)
        return cellSize
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

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
