//
//  ItemOverviewController.swift
//  Butter
//
//  Created by Moorice on 11-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import UIKit

class ItemOverviewController: UICollectionViewController, UISearchBarDelegate, TablePickerViewDelegate {
    
	var searchBar: UISearchBar?
	var tablePickerView: TablePickerView?
    var refreshControl : UIRefreshControl?
    var nothingFoundLabel : UILabel?
    var searchBarPlaceholder = "Search..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add searchbar
        addSearchbar()
		
		// Add TablePicker for filter
		addTablePicker()
        
        // Add refresh control
        addRefreshControl()
        
        // Add label with Nothing Found text
        addNothingFoundLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleRequestError:"), name:"NSURLErrorDomainErrors", object: nil)
    }
	
	override func viewWillDisappear(animated: Bool) {
		tablePickerView?.hide()
	}
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NSURLErrorDomainErrors", object: nil)
    }
	
    func handleRequestError(notification: NSNotification) {
        if let userInfo = notification.userInfo as? Dictionary<String, NSError> {
            if let error = userInfo["error"] {

                let errorAlert = UIAlertController(title: "Oops..", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)

                errorAlert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (action: UIAlertAction!) in
                    self.reloadItems()
                }))
                
                errorAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action: UIAlertAction!) in
                    
                }))
                
                presentViewController(errorAlert, animated: true, completion: nil)
            }
        }
    }
    
    func addSearchbar() {
        searchBar = UISearchBar.init(frame: CGRect(x: 0, y: 0, width: self.collectionView!.frame.width, height: 44))
        searchBar?.delegate = self
        searchBar?.searchBarStyle = .Minimal
        searchBar?.placeholder = searchBarPlaceholder
        searchBar?.hidden = true
        searchBar?.alpha = 0.0
        (searchBar?.valueForKey("searchField") as? UITextField)?.textColor = UIColor.whiteColor()
        self.collectionView?.addSubview(searchBar!)
    }
	
	func addTablePicker() {
		tablePickerView = TablePickerView(superView: self.view, sourceArray: nil, self)
		tablePickerView?.setCellBackgroundColor(UIColor.clearColor())
		tablePickerView?.setCellTextColor(UIColor.lightGrayColor())
		tablePickerView?.setCellSeperatorColor(UIColor.darkGrayColor())
		tablePickerView?.tableView.backgroundColor = UIColor.clearColor()
		tablePickerView?.setSelected(["All"])
		let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
		tablePickerView?.tableView.backgroundView = blurEffectView
		
		self.tabBarController?.view.addSubview(tablePickerView!)
	}
    
    func setSearchBarPlaceholderTo(text : String) {
        searchBar?.placeholder = text
    }
    
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: Selector("refreshControlAction"), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView?.addSubview(refreshControl!)
    }
    
    func searchButtonClicked() {
        if let searchBar = self.searchBar {
            UIView.animateWithDuration(0.2, animations: {
                searchBar.alpha = searchBar.hidden ? 1 : 0
                (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = searchBar.hidden ? UIEdgeInsets(top: 44, left: 5, bottom: 0, right: 5) : UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
                }, completion: {(finished: Bool) in
                    if(finished) {
                        searchBar.hidden = !searchBar.hidden
                        if searchBar.hidden {
                            searchBar.resignFirstResponder()
                            ButterAPIManager.sharedInstance.searchString = ""
                        }
                        if self.collectionView!.numberOfSections() > 0 && self.collectionView!.numberOfItemsInSection(0) > 0 && !searchBar.hidden {
                            self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
                        }
                    }
            })
        }
    }
	
	func filterButtonClicked() {
		tablePickerView?.toggle()
	}
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        ButterAPIManager.sharedInstance.searchString = searchBar.text!
        self.reloadItems()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.view.endEditing(true)
            ButterAPIManager.sharedInstance.searchString = ""
            self.reloadItems()
        }
    }
	
	func tablePickerView(tablePickerView: TablePickerView, var didClose items: [String]) {
		if items.count == 0 {
			items = ["All"]
			tablePickerView.setSelected(items)
		}
		
		ButterAPIManager.sharedInstance.genres = items
		self.reloadItems()
	}
	
	func tablePickerView(tablePickerView: TablePickerView, didSelect item: String) {
		if item == "All" {
			tablePickerView.deselectButThis(item)
		} else {
			tablePickerView.deselect("All")
		}
	}
    
    func refreshControlAction() {
        refreshControl?.endRefreshing()
        reloadItems()
    }
    
    func reloadItems() {
        // Override this method
    }
    
    func addNothingFoundLabel() {
        nothingFoundLabel = UILabel(frame: UIScreen.mainScreen().bounds)
        nothingFoundLabel!.text = "Nothing found.."
        nothingFoundLabel!.textAlignment = NSTextAlignment.Center
        nothingFoundLabel!.textColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1.0)
        nothingFoundLabel!.font = UIFont.systemFontOfSize(24.0)
        nothingFoundLabel!.hidden = true
        self.view.addSubview(nothingFoundLabel!)
    }
    
    func showNothingFound(show : Bool) {
        nothingFoundLabel!.hidden = !show
    }
}
