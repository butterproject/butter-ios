//
//  MovieFavorites.swift
//  Butter
//
//  Created by Moorice on 28-09-15.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SQLite

public class MovieFavorites {
	
	private static let movieFavorites = Table("MovieFavorites")
	private static let imdb_id = Expression<String>("imdb_id")
	
	private class func prepareTable() throws {
		try DatabaseManager.sharedDb?.run(movieFavorites.create(temporary: false, ifNotExists: true, block: { t in
			t.column(imdb_id, primaryKey: true)
		}))
	}
	
	public class func addFavorite(imdbId : String) -> Int64? {
		do {
			try prepareTable()
			let insert = movieFavorites.insert(imdb_id <- imdbId)
			return try DatabaseManager.sharedDb?.run(insert)
		} catch {
			return nil
		}
	}
	
	public class func removeFavorite(imdbId : String) -> Int {
		do {
			try prepareTable()
			let media = movieFavorites.filter(imdb_id == imdbId)
			return try DatabaseManager.sharedDb!.run(media.delete())
		} catch {
			return 0
		}
	}
	
	public class func isFavorite(imdbId : String) -> Bool {
		do {
			try prepareTable()
			return (DatabaseManager.sharedDb?.scalar(movieFavorites.filter(imdb_id == imdbId).count) > 0)
		} catch {
			return false
		}
	}
	
	public class func getFavorites() -> [String]? {
		do {
			try prepareTable()
			return DatabaseManager.sharedDb?.prepare(movieFavorites).map({ $0[imdb_id] })
		} catch {
			return nil
		}
	}
	
	public class func toggleFavorite(imdbId : String) {
		if isFavorite(imdbId) {
			removeFavorite(imdbId)
		} else {
			addFavorite(imdbId)
		}
	}
}
