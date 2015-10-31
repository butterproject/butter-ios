//
//  AppDelegate.swift
//  Butter
//
//  Created by DjinnGA on 23/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import UIKit
import Reachability

let reuseIdentifier = "coverCell"
let movieCellIdentifier = "movieCell"
let TVCellIdentifier = "TVCell"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Set default searchstring (empty)
        ButterAPIManager.sharedInstance.searchString = ""
        
        // Set tint color for application (used for back buttons)
        window?.tintColor = UIColor(red:0.37, green:0.41, blue:0.91, alpha:1.0)
        
        // Start reachability class to watch the users internet connection
        reachability = Reachability.reachabilityForInternetConnection()
        reachability!.startNotifier()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        
        return true
    }
    
    func reachabilityChanged(notification: NSNotification) {
        if !reachability!.isReachableViaWiFi() && !reachability!.isReachableViaWWAN() {
            dispatch_async(dispatch_get_main_queue(), {
                let errorAlert = UIAlertController(title: "Oops..", message: "You are not connected to the internet anymore. Please make sure you have internet access", preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in }))
                self.window?.rootViewController?.presentViewController(errorAlert, animated: true, completion: nil)
            })
        }
    }
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		if url.absoluteString.containsString("magnet:") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController:UITabBarController = storyboard.instantiateInitialViewController() as! UITabBarController
            
            let onWifi : Bool = (UIApplication.sharedApplication().delegate! as! AppDelegate).reachability!.isReachableViaWiFi()
            let wifiOnly : Bool = !NSUserDefaults.standardUserDefaults().boolForKey("StreamOnCellular")
            
            if !wifiOnly || onWifi {
                let loadingVC = storyboard.instantiateViewControllerWithIdentifier("loadingViewController") as! ButterLoadingViewController
                //loadingVC.delegate = self
                loadingVC.status = "Downloading..."
                loadingVC.loadingTitle = "Web Magnet"
                loadingVC.bgImg = nil
                loadingVC.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                self.window?.rootViewController?.presentViewController(loadingVC, animated: true, completion: nil)
                
                let magnetLink = url.absoluteString;
                let runtime = 120;
                
                ButterTorrentStreamer.sharedStreamer().startStreamingFromFileOrMagnetLink(magnetLink, runtime: Int32(runtime), progress: { (status) -> Void in
                    
                    loadingVC.progress = status.bufferingProgress
                    loadingVC.speed = Int(status.downloadSpeed)
                    loadingVC.seeds = Int(status.seeds)
                    loadingVC.peers = Int(status.peers)
                    
                    }, readyToPlay: { (url) -> Void in
                        loadingVC.dismissViewControllerAnimated(false, completion: nil)
                        
                        let vdl = VDLPlaybackViewController(nibName: "VDLPlaybackViewController", bundle: nil)
                        //vdl.delegate = self
                        self.window?.rootViewController?.presentViewController(vdl, animated: true, completion: nil)
                        vdl.playMediaFromURL(url)
                        
                    }, failure: { (error) -> Void in
                        loadingVC.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                let errorAlert = UIAlertController(title: "Cellular Data is Turned Off for streaming", message: "To enable it please go to settings.", preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in }))
                errorAlert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let settingsVc = storyboard.instantiateViewControllerWithIdentifier("SettingsView") as! SettingsTableViewController
                    //navigationController.pushViewController(settingsVc, animated: true)
                }))
                self.window?.rootViewController?.presentViewController(errorAlert, animated: true, completion: nil)
            }

		}

		return true
	}

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

