//
//  MovieDetailViewController.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import UIKit
import FloatRatingView
import XCDYouTubeKit

class MovieDetailViewController: UIViewController, ButterLoadingViewControllerDelegate, VDLPlaybackViewControllerDelegate, TablePickerViewDelegate, UIActionSheetDelegate {

    @IBOutlet var fanartTopImageView: UIImageView!
    @IBOutlet var fanartBottomImageView: UIImageView!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var itemTitleLabelView: UILabel!
    @IBOutlet var itemDetailsLabelView: UILabel!
    @IBOutlet var itemSynopsisTextView: UITextView!
    @IBOutlet var itemRatingView: FloatRatingView!
    @IBOutlet var qualityBtn: UIButton!
	@IBOutlet weak var subtitlesButton: UIButton!
    
    var loadingVC: ButterLoadingViewController?
    var currentItem: ButterItem?
    
    var quality: String = "720p"
    var qualityIDs :[String] = []
	
	var subtitles = [String : String]()
	var selectedSubtitleURL : String?
	
	var favouriteBtn : UIBarButtonItem!
	var watchedBtn : UIBarButtonItem!
	var subtitlesTablePickerView : TablePickerView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        //Load data onto the view
		self.fanartTopImageView.alpha = 0.0
		self.fanartBottomImageView.alpha = 0.0
		
		fillView()
		
        if (!currentItem!.hasProperty("fanart")) {
            TraktTVAPI.sharedInstance.requestMovieInfo(currentItem!.getProperty("imdb") as! String!, onCompletion: {
				self.fillView()
            })
        }
		
		addSubtitlesTablePicker()
		YIFYSubtitles.sharedInstance.getSubtitle(currentItem!.getProperty("imdb") as! String!) { (subtitlesPerLanguageCode) in
			self.subtitles = subtitlesPerLanguageCode
			self.subtitlesTablePickerView?.setSourceDictionay(subtitlesPerLanguageCode)
            
            if let preferredLang = NSUserDefaults.standardUserDefaults().objectForKey("PreferredSubtitleLanguage") as? String {
                if preferredLang != "None" {
                    let lang = ButterAPIManager.languages[preferredLang]!
                    if subtitlesPerLanguageCode.allKeysForValue(lang).count > 0 {
                        let key = subtitlesPerLanguageCode.allKeysForValue(lang)[0]
                        self.subtitlesTablePickerView?.setSelected([key])
                        self.selectedSubtitleURL = key
                        self.subtitlesButton.setTitle(lang + " ▾", forState: .Normal)
                    }
                }
            }
            
		}
		
		// Add Watched and Favourites Buttons
		favouriteBtn = UIBarButtonItem(image: getFavoriteButtonImage(), style: .Plain, target: self, action: Selector("toggleFavorite"))
		watchedBtn = UIBarButtonItem(image: getWatchedButtonImage(), style: .Plain, target: self, action: Selector("toggleWatched"))
		self.navigationItem.setRightBarButtonItems([favouriteBtn, watchedBtn], animated:false)
        
        
        // Set Paralax Effect on Fanart
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
            type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -15
        verticalMotionEffect.maximumRelativeValue = 15
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
            type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -15
        horizontalMotionEffect.maximumRelativeValue = 15
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        fanartTopImageView.addMotionEffect(group)
        fanartBottomImageView.addMotionEffect(group)
    }
	
	func fillView() {
        if let currentItem = currentItem {
            coverImageView.image = currentItem.getProperty("cover") as? UIImage
            itemTitleLabelView.text = currentItem.getProperty("title") as? String
            
            if let fanArt = currentItem.getProperty("fanart") as? UIImage {
                setFanArt(fanArt)
            }
            
            if let description = currentItem.getProperty("description") as? String {
                self.itemSynopsisTextView.text = description
            } else {
                self.itemSynopsisTextView.text = ""
            }
            
            if let rating = currentItem.getProperty("rating") as? Double {
                itemRatingView.rating = Float(rating/2)
            }
            
            if let gen = currentItem.getProperty("genres") as? String {
                if let yr = currentItem.getProperty("year") as? Int {
                    if let run = currentItem.getProperty("runtime") as? Int {
                        itemDetailsLabelView.text = "\(gen) ● \(yr) ● \(run) min."
                    }
                }
            }
        }
	}
	
	func addSubtitlesTablePicker() {
		subtitlesTablePickerView = TablePickerView(superView: self.view, sourceDict: nil, self)
		subtitlesTablePickerView?.setCellBackgroundColor(UIColor.clearColor())
		subtitlesTablePickerView?.setCellTextColor(UIColor.lightGrayColor())
		subtitlesTablePickerView?.setCellSeperatorColor(UIColor.darkGrayColor())
		subtitlesTablePickerView?.tableView.backgroundColor = UIColor.clearColor()
		subtitlesTablePickerView?.setMultipleSelect(false)
		subtitlesTablePickerView?.setNullAllowed(true)
		let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
		subtitlesTablePickerView?.tableView.backgroundView = blurEffectView
		self.tabBarController?.view.addSubview(subtitlesTablePickerView!)
	}
	
    override func viewWillAppear(animated: Bool) {
        // Do any additional setup after loading the view.
        // Set the navigation bar to transparent and tint to white.
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics:UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.view.backgroundColor = UIColor.clearColor()
        self.navigationController!.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics:UIBarMetrics.Default)
    }
	
	func setFanArt(image : UIImage) {
		self.fanartTopImageView.image = image
		let flippedImage: UIImage = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation:UIImageOrientation.DownMirrored)
		self.fanartBottomImageView.image = flippedImage
		
		UIView.animateWithDuration(0.2, animations: { () -> Void in
			self.fanartTopImageView.alpha = 1
			self.fanartBottomImageView.alpha = 1
		})
	}
	
    func getFavoriteButtonImage() -> UIImage? {
        var favImage = UIImage(named: "favoritesOff")?.imageWithRenderingMode(.AlwaysOriginal)
        if let currentItem = currentItem {
            if MovieFavorites.isFavorite(currentItem.getProperty("imdb") as! String) {
                favImage = UIImage(named: "favoritesOn")?.imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        return favImage
    }
    
    func getWatchedButtonImage() -> UIImage? {
        var watchedImage = UIImage(named: "watchedOff")?.imageWithRenderingMode(.AlwaysOriginal)
        if let currentItem = currentItem {
            if WatchedMovies.isWatched(currentItem.getProperty("imdb") as! String) {
                watchedImage = UIImage(named: "watchedOn")?.imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        return watchedImage
    }
	
	func toggleFavorite() {
		if let currentItem = currentItem {
			MovieFavorites.toggleFavorite(currentItem.getProperty("imdb") as! String)
			favouriteBtn.image = getFavoriteButtonImage()
		}
	}
    
    func toggleWatched() {
        if let currentItem = currentItem {
            WatchedMovies.toggleWatched(currentItem.getProperty("imdb") as! String)
            watchedBtn.image = getWatchedButtonImage()
        }
    }
    
    @IBAction func changeQualityTapped(sender: UIButton) {
        if (currentItem!.torrents.count > 1) {
            if objc_getClass("UIAlertController") != nil {
                let qualitySheet: UIAlertController = UIAlertController(title:"Select Quality", message:nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
                for (_, thisTor) in currentItem!.torrents {
                    qualitySheet.addAction(UIAlertAction(title: "\(thisTor.quality)   \(thisTor.size)", style: .Default, handler: { action in
                        self.quality = thisTor.quality
                        self.qualityBtn.setTitle("\(self.quality) ▾", forState: .Normal)
                    }))
                }
				qualitySheet.popoverPresentationController?.sourceView = sender as UIView // provide a popover sourceView on iPad
                self.presentViewController(qualitySheet, animated: true, completion: nil)
            } else {
                let qualitySheet: UIActionSheet = UIActionSheet(title: "Select Quality", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                for (_, thisTor) in currentItem!.torrents {
                    qualitySheet.addButtonWithTitle("\(thisTor.quality)   \(thisTor.size)")
                    qualityIDs.append(thisTor.quality)
                }
                qualitySheet.showInView(self.view)
            }
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        quality = qualityIDs[buttonIndex]
        self.qualityBtn.setTitle("\(quality) ▾", forState: .Normal)
    }
    
    @IBAction func changeSubtitlesTapped(sender: UIButton) {
        subtitlesTablePickerView?.toggle()
    }
    
    @IBAction func watchNowTapped(sender: UIButton) {
        
        let onWifi : Bool = (UIApplication.sharedApplication().delegate! as! AppDelegate).reachability!.isReachableViaWiFi()
        let wifiOnly : Bool = !NSUserDefaults.standardUserDefaults().boolForKey("StreamOnCellular")
        
        if !wifiOnly || onWifi {
            loadingVC = self.storyboard?.instantiateViewControllerWithIdentifier("loadingViewController") as! ButterLoadingViewController
            loadingVC!.delegate = self
            loadingVC!.status = "Downloading..."
            loadingVC!.loadingTitle = currentItem!.getProperty("title") as? String
            loadingVC!.bgImg = coverImageView.image!
            loadingVC!.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            self.presentViewController(loadingVC!, animated: true, completion: nil)
            
            let runtime = currentItem!.getProperty("runtime") as! Int
            
            if (currentItem!.torrents[quality]!.hash != "") {
                let magnetLink: String = ButterAPIManager.sharedInstance.makeMagnetLink(currentItem!.torrents[quality]!.hash, title: currentItem!.getProperty("title") as! String)
                loadMovieTorrent(magnetLink, runtime: runtime)
            } else {
                RestApiManager.sharedInstance.makeAsyncDataRequest(currentItem!.torrents[quality]!.url, onCompletion: saveTorrentToFile)
            }
            
        } else {
            let errorAlert = UIAlertController(title: "Cellular Data is Turned Off for streaming", message: "To enable it please go to settings.", preferredStyle: UIAlertControllerStyle.Alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in }))
            errorAlert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action: UIAlertAction!) in
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let settingsVc = storyboard.instantiateViewControllerWithIdentifier("SettingsView") as! SettingsTableViewController
                self.navigationController?.pushViewController(settingsVc, animated: true)
            }))
            self.presentViewController(errorAlert, animated: true, completion: nil)
        }
    }
    
    func saveTorrentToFile(torrent: NSData) {
        let url: NSURL = NSURL(string: currentItem!.torrents[quality]!.url)!
        let runtime = currentItem!.getProperty("runtime") as! Int
        
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
        } else {
            if torrent.writeToURL(destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path!)]")
                loadMovieTorrent(destinationUrl.path!, runtime: runtime)
            } else {
                print("error saving file")
            }
        }
    }
    
    func loadMovieTorrent(torrURL: String, runtime: Int) {
        ButterTorrentStreamer.sharedStreamer().startStreamingFromFileOrMagnetLink(torrURL, runtime: Int32(runtime), progress: { (status) -> Void in
            
            self.loadingVC!.progress = status.bufferingProgress
            self.loadingVC!.speed = Int(status.downloadSpeed)
            self.loadingVC!.seeds = Int(status.seeds)
            self.loadingVC!.peers = Int(status.peers)
            
            }, readyToPlay: { (url) -> Void in
                self.loadingVC!.dismissViewControllerAnimated(false, completion: nil)
                
                let vdl = VDLPlaybackViewController(nibName: "VDLPlaybackViewController", bundle: nil)
                vdl.delegate = self
                self.navigationController?.presentViewController(vdl, animated: true, completion: nil)
                vdl.playMediaFromURL(url)
                
            }, failure: { (error) -> Void in
                self.loadingVC!.dismissViewControllerAnimated(true, completion: nil)
        })
    }
	
	@IBAction func coverTapped(sender: AnyObject) {
		if let trailer = currentItem?.getProperty("trailer") as? String {
			let splitted = trailer.componentsSeparatedByString("?v=")
			if let id = splitted.last {
				let vc = XCDYouTubeVideoPlayerViewController(videoIdentifier: id)
				presentMoviePlayerViewControllerAnimated(vc)
			}
		}
	}
	
	func tablePickerView(tablePickerView: TablePickerView, didChange items: [String]) {
		if items.count == 0 {
			selectedSubtitleURL = nil
			subtitlesButton.setTitle("None ▾", forState: .Normal)
		} else {
			selectedSubtitleURL = items[0]
			subtitlesButton.setTitle(subtitles[items[0]]! + " ▾", forState: .Normal)
		}
	}

    // MARK: - PlaybackViewControllerDelegate
    func playbackControllerDidFinishPlayback(playbackController: VDLPlaybackViewController!) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        ButterTorrentStreamer.sharedStreamer().cancelStreaming()
    }
    
    // MARK: - ButterLoadingViewControllerDelegate
    func didCancelLoading(controller: ButterLoadingViewController) {
        ButterTorrentStreamer.sharedStreamer().cancelStreaming()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
