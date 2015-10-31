//
//  SettingsTableViewController.swift
//  Butter
//
//  Created by Moorice on 11-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import UIKit
import SafariServices

class SettingsTableViewController: UITableViewController, TablePickerViewDelegate {

    let ud = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var switchStreamOnCellular: UISwitch!
    @IBOutlet weak var segmentedQuality: UISegmentedControl!
	@IBOutlet weak var languageButton: UIButton!
	
	var tablePickerView : TablePickerView?
    let qualities = ["480p", "720p", "1080p"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		addTablePicker()
        showSettings()
    }
    
    func showSettings() {        
        // Set StreamOnCellular
        switchStreamOnCellular.on = ud.boolForKey("StreamOnCellular")
		
		// Set preferred subtitle language
		if let preferredSubtitleLanguage = ud.objectForKey("PreferredSubtitleLanguage") as? String {
            if preferredSubtitleLanguage != "None" {
                tablePickerView?.setSelected([preferredSubtitleLanguage])
                languageButton.setTitle(ButterAPIManager.languages[preferredSubtitleLanguage], forState: .Normal)
            } else {
                languageButton.setTitle("None", forState: .Normal)
            }
		} else {
			let usersLang = NSLocale.get2LetterLanguageCode()
			
			// Set (and save) preferred subtitle language to users' locale when locale is in language list
			if let _ = ButterAPIManager.languages[usersLang] {
				ud.setObject(usersLang, forKey: "PreferredSubtitleLanguage")
                tablePickerView?.setSelected([usersLang])
                languageButton.setTitle(ButterAPIManager.languages[usersLang], forState: .Normal)
            } else {
                languageButton.setTitle("None", forState: .Normal)
            }
		}
		
        // Set preferred quality
        let qualityInSettings = ud.objectForKey("PreferredQuality") as? String
        var selectedQualityIndex = 0
        segmentedQuality.removeAllSegments()
        for (index, quality) in qualities.enumerate() {
            segmentedQuality.insertSegmentWithTitle(quality, atIndex: index, animated: true)
            if let qualityInSettings = qualityInSettings {
                if quality == qualityInSettings {
                    selectedQualityIndex = index
                }
            }
        }
        
        segmentedQuality.selectedSegmentIndex = selectedQualityIndex
    }
	
	func addTablePicker() {
		tablePickerView = TablePickerView(superView: self.view, sourceDict: ButterAPIManager.languages, self)
		tablePickerView?.setCellBackgroundColor(UIColor.clearColor())
		tablePickerView?.setCellTextColor(UIColor.lightGrayColor())
		tablePickerView?.setCellSeperatorColor(UIColor.darkGrayColor())
		tablePickerView?.tableView.backgroundColor = UIColor.clearColor()
		tablePickerView?.setMultipleSelect(false)
		tablePickerView?.setNullAllowed(true)
		let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
		tablePickerView?.tableView.backgroundView = blurEffectView
		self.tabBarController?.view.addSubview(tablePickerView!)
	}
    
    func tablePickerView(tablePickerView: TablePickerView, didChange items: [String]) {
        if items.count > 0 {
            ud.setObject(items[0], forKey: "PreferredSubtitleLanguage")
            languageButton.setTitle(ButterAPIManager.languages[items[0]], forState: .Normal)
        } else {
            ud.setObject("None", forKey: "PreferredSubtitleLanguage")
            languageButton.setTitle("None", forState: .Normal)
        }
    }
	
	override func viewWillDisappear(animated: Bool) {
		tablePickerView?.hide()
	}
    
    override func viewDidDisappear(animated: Bool) {
        ud.synchronize()
    }
    
    @IBAction func streamOnCellular(sender: UISwitch) {
        ud.setBool(sender.on, forKey: "StreamOnCellular")
    }
    
    @IBAction func preferredQuality(control: UISegmentedControl) {
        let resultAsText = control.titleForSegmentAtIndex(control.selectedSegmentIndex)
        ud.setObject(resultAsText, forKey: "PreferredQuality")
    }
	
	@IBAction func preferredSubtitleLanguage(sender: AnyObject) {
		tablePickerView?.toggle()
	}
    
    @IBAction func authorizeTraktTV(sender: AnyObject) {
        let alert = UIAlertController(title: "Not yet supported", message: "Trakt.TV integration is in development.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func showTwitter(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/butterproject")!)
    }
    
    @IBAction func showWebsite(sender: AnyObject) {
        openUrl("http://butterproject.org")
    }
    
    func openUrl(url : String) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: NSURL(string: url)!)
            svc.view.tintColor = UIColor(red:0.37, green:0.41, blue:0.91, alpha:1.0)
            self.presentViewController(svc, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
}
