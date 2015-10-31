//
//  TVShowsCollectionViewController.swift
//  Butter
//
//  Created by DjinnGA on 23/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import UIKit
import JGProgressHUD

class TVShowsCollectionViewController: ItemOverviewController {
    
    let itemsPerRow: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "TV Shows"
		
		self.tablePickerView?.setSourceArray(TVAPI.genres)
		self.tablePickerView?.setMultipleSelect(false)
        self.setSearchBarPlaceholderTo("Search for a TV Show...")
        self.reloadItems()
    }
    
    override func reloadItems() {
        let hud = JGProgressHUD(style: .Dark)
        hud.showInView(self.view)
		ButterAPIManager.sharedInstance.loadTVShows { (newItems) in
            hud.dismiss()
			if newItems {
				self.collectionView?.reloadData()
				if ButterAPIManager.sharedInstance.isSearching {
					self.showNothingFound(ButterAPIManager.sharedInstance.searchResults.count == 0)
				} else {
					self.showNothingFound(ButterAPIManager.sharedInstance.cachedTVShows.count == 0)
				}
			}
        }
    }
    
    @IBAction func search(sender: AnyObject) {
        searchButtonClicked()
    }

	@IBAction func filter(sender: AnyObject) {
		filterButtonClicked()
	}	
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destinationViewController as! TVShowDetailViewController
            let cell = sender as! PTCoverCollectionViewCell
            if ButterAPIManager.sharedInstance.isSearching {
                if let item = ButterAPIManager.sharedInstance.searchResults[self.collectionView!.indexPathForCell(cell)!.row] {
                    detailVC.currentItem = item
                    return
                }
            } else {
                if let item = ButterAPIManager.sharedInstance.cachedTVShows[self.collectionView!.indexPathForCell(cell)!.row] {
                    detailVC.currentItem = item
                    return
                }
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        if ButterAPIManager.sharedInstance.isSearching {
            return ButterAPIManager.sharedInstance.searchResults.count
        }
        return ButterAPIManager.sharedInstance.cachedTVShows.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PTCoverCollectionViewCell
        
        var tmpCache =  OrderedDictionary<String,ButterItem>()
        
        if ButterAPIManager.sharedInstance.isSearching {
            tmpCache = ButterAPIManager.sharedInstance.searchResults
        } else {
            tmpCache = ButterAPIManager.sharedInstance.cachedTVShows
        }
        
        if (indexPath.row == tmpCache.count-1) {
            self.reloadItems()
        }
        
        // Configure the cell
        if let ite: ButterItem = tmpCache[indexPath.row] as ButterItem! {
            if let img: UIImage = ite.getProperty("cover") as? UIImage {
                cell.coverImage.image = img
            } else {
                cell.coverImage.image = UIImage(named: "cover-placeholder")
                RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String) { image in
                    if ButterAPIManager.sharedInstance.isSearching {
                        ButterAPIManager.sharedInstance.searchResults[indexPath.row]!.setProperty("cover", val: image)
                    } else {
                        ButterAPIManager.sharedInstance.cachedTVShows[indexPath.row]!.setProperty("cover", val: image)
                    }
                    if let cell: PTCoverCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as? PTCoverCollectionViewCell {
                        cell.coverImage.image = image
                        let animation: CATransition = CATransition()
                        animation.duration = 1.0
                        animation.type = kCATransitionFade//"rippleEffect" //pageUnCurl
                        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                        cell.coverImage.layer.addAnimation(animation, forKey:nil)
                    }
                }
            }
            if let title: String = ite.getProperty("title") as? String {
                cell.titleLabel.text = title
            }
            
            if let seasons: Int = ite.getProperty("seasons") as? Int {
                cell.seasonsLabel.text = "\(seasons) Seasons"
            }
            
            if let year: String = ite.getProperty("year") as? String {
                cell.yearLabel.text = year
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let wid = (self.collectionView!.bounds.width/CGFloat(itemsPerRow))-10
        let ratio = 230/wid
        let hei = 345/ratio
        
        let cellSize:CGSize = CGSizeMake(wid, hei)
        return cellSize
    }

}
