//
//  FavouritesCollectionViewController.swift
//  Butter
//
//  Created by DjinnGA on 23/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import UIKit

class FavouritesCollectionViewController: UICollectionViewController {
    
    let itemsPerRow: Int = 2
    var currentSection: MediaType = .Movies
    var favorites: [String] = [String]()
    
    enum MediaType : Int {
        case Movies, Shows
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favourites"
    }
    
    @IBAction func changeMediaType(sender: UISegmentedControl) {
        currentSection = MediaType(rawValue: sender.selectedSegmentIndex)!
        reloadFavorites()
    }
    
    func reloadFavorites() {
        if currentSection == .Movies {
            favorites = MovieFavorites.getFavorites()!
        } else {
            favorites = ShowFavorites.getFavorites()!
        }
        
        for e in favorites {
			MovieAPI.sharedInstance.getMovie(e, onCompletion: { (loadedFromCache) -> Void in
				self.collectionView?.reloadData()
			})
        }
        
        self.collectionView?.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadFavorites()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! PTCoverCollectionViewCell
        let indexPath = self.collectionView!.indexPathForCell(cell)
        
        if currentSection == .Movies {
            let detailVC = segue.destinationViewController as! MovieDetailViewController
            if let item = ButterAPIManager.sharedInstance.cachedMovies[favorites[indexPath!.row]] {
                detailVC.currentItem = item
            }
        } else {
            let detailVC = segue.destinationViewController as! TVShowDetailViewController
            if let item = ButterAPIManager.sharedInstance.cachedTVShows[favorites[indexPath!.row]] {
                detailVC.currentItem = item
            }
        }
    }
    
    func getMovieCell(imdbId : String, indexPath: NSIndexPath) -> PTCoverCollectionViewCell {
        let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(movieCellIdentifier, forIndexPath: indexPath) as! PTCoverCollectionViewCell
		
		MovieAPI.sharedInstance.getMovie(imdbId) { (loadedFromCache) -> Void in
			if let ite: ButterItem = ButterAPIManager.sharedInstance.cachedMovies[imdbId] as ButterItem! {
				if let img: UIImage = ite.getProperty("cover") as? UIImage {
					cell.coverImage.image = img
				} else {
					cell.coverImage.image = UIImage(named: "cover-placeholder")
					RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String) { image in
						ButterAPIManager.sharedInstance.cachedMovies[imdbId]!.setProperty("cover", val: image)
						if let cell: PTCoverCollectionViewCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as? PTCoverCollectionViewCell {
							cell.coverImage.image = image
							let animation: CATransition = CATransition()
							animation.duration = 1.0
							animation.type = kCATransitionFade
							animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
							cell.coverImage.layer.addAnimation(animation, forKey:nil)
						}
					}
				}
				if let title: String = ite.getProperty("title") as? String {
					cell.titleLabel.text = title
				}
				if let year: Int = ite.getProperty("year") as? Int {
					cell.yearLabel.text = "\(year)"
				}
			}
		}
		
        return cell
    }
	
    func getTVShowCell(imdbId : String, indexPath: NSIndexPath) -> PTCoverCollectionViewCell {
        let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(TVCellIdentifier, forIndexPath: indexPath) as! PTCoverCollectionViewCell
		
		TVAPI.sharedInstance.getShow(imdbId) { (loadedFromCache) -> Void in
			if let ite: ButterItem = ButterAPIManager.sharedInstance.cachedTVShows[imdbId] as ButterItem! {
				if let img: UIImage = ite.getProperty("cover") as? UIImage {
					cell.coverImage.image = img
				} else {
					cell.coverImage.image = UIImage(named: "cover-placeholder")
					RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String) { image in
						ButterAPIManager.sharedInstance.cachedTVShows[imdbId]!.setProperty("cover", val: image)
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
				
				if(!loadedFromCache) {
					self.collectionView?.reloadData()
				}
			}
		}
		
        return cell
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return favorites.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if currentSection == .Movies {
            return getMovieCell(favorites[indexPath.row], indexPath: indexPath)
        } else {
            return getTVShowCell(favorites[indexPath.row], indexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let wid = (self.collectionView!.bounds.width/CGFloat(itemsPerRow))-10
        let ratio = 230/wid
        let hei = 345/ratio
        
        let cellSize:CGSize = CGSizeMake(wid, hei)
        return cellSize
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "favHeader", forIndexPath: indexPath) as! FavouritesHeaderCollectionReusableView
        
        var singular = ""
        var plural = ""
        
        if currentSection == .Movies {
            singular = "Movie Favourited"
            plural = "Movies Favourited"
        } else {
            singular = "TV Show Favourited"
            plural = "TV Shows Favourited"
        }
        
        if (favorites.count == 1) {
            headerView.itemCountLabel.text = "\(favorites.count) \(singular)"
        } else {
            headerView.itemCountLabel.text = "\(favorites.count) \(plural)"
        }
        
        return headerView
    }
}
