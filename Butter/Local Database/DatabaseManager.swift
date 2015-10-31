//
//  LocalDatabaseManager.swift
//  Butter
//
//  Created by Moorice on 28-09-15.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SQLite

public class DatabaseManager {
	
	static let sharedDb : Connection? = DatabaseManager.getSharedDatabase()
	
	private class func getSharedDatabase() -> Connection? {
		do {
			let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
			let fileURL = documents.URLByAppendingPathComponent("ButterDatabase.sqlite")
			return try Connection(fileURL.absoluteString)
		} catch {
			return nil
		}
	}
}