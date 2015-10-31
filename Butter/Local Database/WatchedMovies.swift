//
//  WatchedMovies.swift
//  Butter
//
//  Created by Moorice on 01-10-15.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SQLite

public class WatchedMovies {
	
	private static let watchedMovies = Table("WatchedMovies")
	private static let imdb_id = Expression<String>("imdb_id")
	private static let play_time = Expression<Int>("play_time")
	
	private class func prepareTable() throws {
		try DatabaseManager.sharedDb?.run(watchedMovies.create(temporary: false, ifNotExists: true, block: { t in
			t.column(imdb_id, primaryKey: true)
			t.column(play_time)
		}))
	}
	
	public class func add(imdbId : String, playTime : Int) -> Int64? {
		do {
			try prepareTable()
			let insert = watchedMovies.insert(imdb_id <- imdbId, play_time <- playTime)
			return try DatabaseManager.sharedDb?.run(insert)
		} catch {
			return nil
		}
	}
	
	public class func add(imdbId : String) -> Int64? {
		return add(imdbId, playTime: 0)
	}
	
	public class func updatePlayTime(imdbId : String, playTime : Int) -> Int? {
		do {
			try prepareTable()
			if isWatched(imdbId) {
				let watched = watchedMovies.filter(imdb_id == imdbId)
				return try DatabaseManager.sharedDb?.run(watched.update(play_time <- playTime))
			} else {
				return nil
			}
		} catch {
			return nil
		}
	}
	
	public class func remove(imdbId : String) -> Int {
		do {
			try prepareTable()
			let media = watchedMovies.filter(imdb_id == imdbId)
			return try DatabaseManager.sharedDb!.run(media.delete())
		} catch {
			return 0
		}
	}
	
	public class func isWatched(imdbId : String) -> Bool {
		do {
			try prepareTable()
			return (DatabaseManager.sharedDb?.scalar(watchedMovies.filter(imdb_id == imdbId).count) > 0)
		} catch {
			return false
		}
	}
	
	public class func getWatched() -> [String]? {
		do {
			try prepareTable()
			return DatabaseManager.sharedDb?.prepare(watchedMovies).map({ $0[imdb_id] })
		} catch {
			return nil
		}
	}
	
	public class func toggleWatched(imdbId : String) {
		if isWatched(imdbId) {
			remove(imdbId)
		} else {
			add(imdbId)
		}
	}
}
