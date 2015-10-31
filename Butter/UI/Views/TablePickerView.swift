//
//  TablePickerView.swift
//  Butter
//
//  Created by Moorice on 12-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import UIKit

@objc public protocol TablePickerViewDelegate {
	optional func tablePickerView(tablePickerView: TablePickerView, didSelect item: String)
	optional func tablePickerView(tablePickerView: TablePickerView, didDeselect item: String)
	optional func tablePickerView(tablePickerView: TablePickerView, didClose items: [String])
	optional func tablePickerView(tablePickerView: TablePickerView, willClose items: [String])
	optional func tablePickerView(tablePickerView: TablePickerView, didChange items: [String])
}

public class TablePickerView: UIView, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet private var view: UIView!
	@IBOutlet public weak var tableView: UITableView!
	@IBOutlet public weak var toolbar: UIToolbar!
	@IBOutlet public weak var button: UIBarButtonItem!
	
	public var delegate : TablePickerViewDelegate?
	private var superView : UIView?
	private var dataSourceKeys = [String]()
	private var dataSourceValues = [String]()
	private (set) public var _selectedItems = [String]()
	private var cellBackgroundColor : UIColor?
	private var cellBackgroundColorSelected : UIColor?
	private var cellTextColor : UIColor?
	private var multipleSelect : Bool = true
	private var nullAllowed : Bool = true
	private var speed : Double = 0.2
	
	// MARK: Init methods
	
	public init(superView: UIView) {
		super.init(frame: CGRectZero)
		self.superView = superView
		prepareView()
	}
	
	public init(superView: UIView, sourceDict: [String : String]?, _ delegate: TablePickerViewDelegate?) {
		super.init(frame: CGRectZero)
		self.superView = superView
		
		if let sourceDict = sourceDict {
			self.setSourceDictionay(sourceDict)
		}
		
		self.delegate = delegate
		prepareView()
	}
	
	public init(superView: UIView, sourceArray: [String]?, _ delegate: TablePickerViewDelegate?) {
		super.init(frame: CGRectZero)
		self.superView = superView
		
		if let sourceArray = sourceArray {
			self.setSourceArray(sourceArray)
		}

		self.delegate = delegate
		prepareView()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		prepareView()
	}
	
	// MARK: Set source and get selectted items
	
	public func setSourceDictionay(source : [String : String]) {
		let sortedKeysAndValues = source.sort({ $0.1 < $1.1 })
		for (key, value) in sortedKeysAndValues {
			self.dataSourceKeys.append(key)
			self.dataSourceValues.append(value)
		}
		tableView?.reloadData()
	}
	
	public func setSourceArray(source : [String]) {
		self.dataSourceKeys = source
		self.dataSourceValues = source
		tableView?.reloadData()
	}
	
	public func setSelected(items : [String]) {
		_selectedItems = items
		tableView?.reloadData()
	}
	
	public func setMultipleSelect(multiple : Bool) {
		multipleSelect = multiple
	}
	
	public func setNullAllowed(multiple : Bool) {
		nullAllowed = multiple
	}
	
	public func deselect(item : String) {
		if let index = _selectedItems.indexOf(item) {
			_selectedItems.removeAtIndex(index)
			tableView?.reloadData()
			delegate?.tablePickerView?(self, didDeselect: item)
		}
	}
	
	public func deselectButThis(item : String) {
		for _item in _selectedItems {
			if _item != item {
				delegate?.tablePickerView?(self, didDeselect: item)
			}
		}
		
		_selectedItems = [item]
		tableView?.reloadData()
	}
	
	public func selectedItems() -> [String] {
		return _selectedItems
	}
	
	// MARK: Style TablePickerView
	// You can also style this view directly since the IBOutlets are public
	
	public func setButtonText(text : String) {
		button.title = text
	}

	public func setToolBarBackground(color : UIColor) {
		toolbar.backgroundColor = color
	}
	
	public func setCellBackgroundColor(color : UIColor) {
		cellBackgroundColor = color
	}
	
	public func setCellBackgroundColorSelected(color : UIColor) {
		cellBackgroundColorSelected = color
	}
	
	public func setCellTextColor(color : UIColor) {
		cellTextColor = color
	}
	
	public func setCellSeperatorColor(color : UIColor) {
		self.tableView.separatorColor = color
	}
	
	public func setAnimationSpeed(speed : Double) {
		self.speed = speed
	}
	
	// MARK: Show / hide view
	
	public func show() {
		if let superView = superView {
			self.hidden = false
			
			var newFrame = self.frame
			newFrame.origin.y = superView.frame.height - self.frame.height
			
			UIView.animateWithDuration(speed, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
				self.frame = newFrame
			}, completion: { (finished) in })
		}
	}
	
	public func hide() {
		if isVisibe() {
			if let superView = superView {
				var newFrame = self.frame
				newFrame.origin.y = superView.frame.height
				
				delegate?.tablePickerView?(self, willClose: selectedItems())
				
				UIView.animateWithDuration(speed, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
					self.frame = newFrame
				}, completion: { (finished) in
					self.hidden = true
					self.delegate?.tablePickerView?(self, didClose: self.selectedItems())
				})
			}
		}
	}
	
	public func toggle() {
		if isVisibe() {
			hide()
		} else {
			show()
		}
	}
	
	public func isVisibe() -> Bool {
		return !self.hidden
	}
	
	
	// MARK: UITabelView
	
	public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSourceKeys.count
	}
	
	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		cell.textLabel?.text = dataSourceValues[indexPath.row]
		
		if let cellBackgroundColor = cellBackgroundColor {
			cell.backgroundColor = cellBackgroundColor
		}
		
		if let cellBackgroundColorSelected = cellBackgroundColorSelected {
			let bg = UIView()
			bg.backgroundColor = cellBackgroundColorSelected
			cell.selectedBackgroundView = bg
		} else {
			let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
			cell.selectedBackgroundView = blurEffectView
		}
		
		if let cellTextColor = cellTextColor {
			cell.textLabel?.textColor = cellTextColor
			cell.tintColor = cellTextColor
		}
		
		if _selectedItems.contains(dataSourceKeys[indexPath.row]) {
			cell.accessoryType = .Checkmark
		} else {
			cell.accessoryType = .None
		}
		
		return cell
	}
	
	public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath)!
		let selectedItem = dataSourceKeys[indexPath.row]

		if _selectedItems.contains(selectedItem) && (nullAllowed || _selectedItems.count > 1) {
			_selectedItems.removeAtIndex(_selectedItems.indexOf(selectedItem)!)
			delegate?.tablePickerView?(self, didDeselect: selectedItem)
			delegate?.tablePickerView?(self, didChange: _selectedItems)
			cell.accessoryType = .None
		} else {
			if !multipleSelect && _selectedItems.count > 0 {
				let oldSelected = _selectedItems[0]
				_selectedItems = []
				if let index = dataSourceKeys.indexOf(oldSelected) {
					let oldCell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: index, inSection: 0))
					oldCell?.accessoryType = .None
				}
			}
			
			_selectedItems.append(selectedItem)
			cell.accessoryType = .Checkmark
			delegate?.tablePickerView?(self, didSelect: selectedItem)
			delegate?.tablePickerView?(self, didChange: _selectedItems)
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	
	// MARK: Private methods
	
	private func prepareView() {
		loadNib()
		
		tableView.tableFooterView = UIView.init(frame: CGRectZero)
		
		let borderTop = CALayer()
		borderTop.frame = CGRectMake(0.0, toolbar.frame.height - 1, toolbar.frame.width, 0.5);
		borderTop.backgroundColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0).CGColor
		toolbar.layer.addSublayer(borderTop)
		
		if let superView = superView {
			self.hidden = true
			
			let height = superView.frame.height / 2.7
			let frameSelf = CGRect(x: 0, y: superView.frame.height, width: superView.frame.width, height: height)
			var framePicker = frameSelf
			framePicker.origin.y = 0
			
			self.frame = frameSelf
			self.view.frame = framePicker
		}
	}
	
	private func loadNib() {
		UINib(nibName: "TablePickerView", bundle: nil).instantiateWithOwner(self, options: nil)[0] as? UIView
		self.addSubview(self.view)
	}
	
	@IBAction func done(sender: AnyObject) {
		hide()
	}
}
