//
//  ReportBugViewController.swift
//  Butter
//
//  Created by Moorice on 17-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ReportBugViewController: UITableViewController {
	
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var titleField: UITextField!
	@IBOutlet weak var descriptionField: PlaceholderTextView!
	@IBOutlet var checkMarks: [UILabel]!
	
	let gitLabApiUrl = "" // ToDo: Add Butter Links
	let gitLabProjectUrl = ""
	let gitLabProjectId = ""
	var gitLabToken : String?
	
	override func viewDidLoad() {
		self.hideCheckmarks()
		
		if let username = NSUserDefaults.standardUserDefaults().objectForKey("GitLabUsername") as? String {
			usernameField.text = username
		}
	}
	
	@IBAction func reportBug(sender: AnyObject) {
		if let _ = gitLabToken {
			if titleField.text?.characters.count < 15 {
				let errorAlert = UIAlertController(title: "Title too short", message: "The title must contain at least 15 characters", preferredStyle: .Alert)
				errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in }))
				self.presentViewController(errorAlert, animated: true, completion: nil)
				return
			}
			
			if descriptionField.text?.characters.count < 100 {
				let errorAlert = UIAlertController(title: "Description too short", message: "The description must contain at least 100 characters", preferredStyle: .Alert)
				self.presentViewController(errorAlert, animated: true, completion: nil)
				errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in }))
				return
			}
			
			let systemVersion = UIDevice.currentDevice().systemVersion;
			let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
			let appBuild = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
			let deviceName = UIDevice.currentDevice().modelName
			let network = (UIApplication.sharedApplication().delegate! as! AppDelegate).reachability!.isReachableViaWiFi() ? "WiFi" : "Cellular"

			let title = titleField.text!
			let description = descriptionField.text! + "\n\n\n ----------------- \n\n" + "iOS: " + systemVersion + "\n\n" + "Device: " + deviceName + "\n\n" + "App version: " + appVersion + "\n\n" + "App build: " + appBuild + "\n\n" + "Network: " + network
			
			createIssue(title, description: description, onCompletion: { (issueUrl) -> Void in
				if let issueUrl = issueUrl {
					let errorAlert = UIAlertController(title: "Reported", message: "Thank you for reporting this issue!", preferredStyle: .Alert)
					errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in
						self.navigationController?.popViewControllerAnimated(true)
					}))
					errorAlert.addAction(UIAlertAction(title: "Open issue", style: .Default, handler: { (action: UIAlertAction!) in
						self.navigationController?.popViewControllerAnimated(true)
						UIApplication.sharedApplication().openURL(NSURL(string: issueUrl)!)
					}))
					self.presentViewController(errorAlert, animated: true, completion: nil)
					
				} else {
					let errorAlert = UIAlertController(title: "Oops..", message: "Something went wrong. Please try it again.", preferredStyle: .Alert)
					errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in }))
					self.presentViewController(errorAlert, animated: true, completion: nil)
				}
			})
			
		} else {
			let errorAlert = UIAlertController(title: "Oops..", message: "Please login with your GitLab account.", preferredStyle: .Alert)
			errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in }))
			errorAlert.addAction(UIAlertAction(title: "Sign up", style: .Default, handler: { (action: UIAlertAction!) in
				UIApplication.sharedApplication().openURL(NSURL(string: "")!)
			}))
			
			self.presentViewController(errorAlert, animated: true, completion: nil)
		}
	}
	
	@IBAction func titleFieldEditingDidBegin(sender: AnyObject) {
		if usernameField.text != "" && passwordField.text != "" {
			getGitLabPrivateToken(usernameField.text!, password: passwordField.text!, onCompletion: { (token) in
				if let token = token {
					self.gitLabToken = token
					self.showCheckmarks()
					NSUserDefaults.standardUserDefaults().setObject(self.usernameField.text!, forKey: "GitLabUsername")
				} else {
					self.hideCheckmarks()
					let errorAlert = UIAlertController(title: "Oops..", message: "The entered username and/or password is invalid", preferredStyle: UIAlertControllerStyle.Alert)
					errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in }))
					self.presentViewController(errorAlert, animated: true, completion: nil)
				}
			})
		}
	}
	
	func getGitLabPrivateToken(username : String, password : String, onCompletion: (String?) -> Void) {
		let jsonBody = [
			"login": username,
			"password": password
		]
		
		do {
			let request = NSMutableURLRequest(URL: NSURL(string: gitLabApiUrl + "session")!)
			request.HTTPMethod = "POST"
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
			
			RestApiManager.sharedInstance.makeHTTPRequest(request, onCompletion: { (json, error) -> Void in
				if let token = json["private_token"].string {
					onCompletion(token)
				} else {
					onCompletion(nil)
				}
			})
		} catch {
			onCompletion(nil)
		}
	}
	
	func createIssue(title : String, description: String, onCompletion: (String?) -> Void) {
		if let gitLabToken = gitLabToken {
			let jsonBody = [
				"id": gitLabProjectId,
				"title": title,
				"description": description
			]
			
			do {
				let request = NSMutableURLRequest(URL: NSURL(string: gitLabApiUrl + "projects/" + gitLabProjectId + "/issues?private_token=" + gitLabToken)!)
				request.HTTPMethod = "POST"
				request.addValue("application/json", forHTTPHeaderField: "Content-Type")
				request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
				
				RestApiManager.sharedInstance.makeHTTPRequest(request, onCompletion: { (json, error) -> Void in
					if let issueId = json["iid"].int {
						onCompletion(self.gitLabProjectUrl + "issues/" + String(issueId))
					} else {
						onCompletion(nil)
					}
				})
			} catch {
				onCompletion(nil)
			}
		}
	}
	
	func showCheckmarks() {
		self.checkMarks.foreach{$0.hidden = false}
	}
	
	func hideCheckmarks() {
		self.checkMarks.foreach{$0.hidden = true}
	}
}
