//
//  WatchedShows.swift
//  Butter
//
//  Created by Moorice on 02-10-15.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SQLite

public class WatchedShows {
	
	private static let watchedShows = Table("WatchedShows")
	private static let imdb_id = Expression<String>("imdb_id")
	private static let season = Expression<Int>("season")
	private static let episode = Expression<Int>("episode")
	private static let play_time = Expression<Int>("play_time")
	
	private class func prepareTable() throws {
		try DatabaseManager.sharedDb?.run(watchedShows.create(temporary: false, ifNotExists: true, block: { t in
			t.column(imdb_id, primaryKey: true)
			t.column(season)
			t.column(episode)
			t.column(play_time)
		}))
	}
	
	public class func add(imdbId : String, seasonNr : Int, episodeNr : Int, playTime : Int) -> Int64? {
		do {
			try prepareTable()
			let insert = watchedShows.insert(imdb_id <- imdbId, season <- seasonNr, episode <- episodeNr, play_time <- playTime)
			return try DatabaseManager.sharedDb?.run(insert)
		} catch {
			return nil
		}
	}
	
	public class func add(imdbId : String) -> Int64? {
		return add(imdbId, seasonNr: 0, episodeNr: 0, playTime: 0)
	}
	
	public class func update(imdbId : String, seasonNr : Int, episodeNr : Int, playTime : Int) -> Int? {
		do {
			try prepareTable()
			if isWatched(imdbId) {
				let watched = watchedShows.filter(imdb_id == imdbId)
				return try DatabaseManager.sharedDb?.run(watched.update(season <- seasonNr, episode <- episodeNr, play_time <- playTime))
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
			let show = watchedShows.filter(imdb_id == imdbId)
			return try DatabaseManager.sharedDb!.run(show.delete())
		} catch {
			return 0
		}
	}
	
	public class func isWatched(imdbId : String) -> Bool {
		do {
			try prepareTable()
			return (DatabaseManager.sharedDb?.scalar(watchedShows.filter(imdb_id == imdbId).count) > 0)
		} catch {
			return false
		}
	}
	
	public class func getWatchedEpisodeInformation(imdbId : String) -> (season : Int, episode : Int, playtime: Int)? {
		do {
			try prepareTable()
			if isWatched(imdbId) {
				if let show = DatabaseManager.sharedDb?.prepare(watchedShows.filter(imdb_id == imdbId)).map({ $0 }) {
					return (show[0][season], show[0][episode], show[0][play_time])
				} else {
					return nil
				}
			} else {
				return nil
			}
		} catch {
			return nil
		}
	}
	
	public class func getWatched() -> [String]? {
		do {
			try prepareTable()
			return DatabaseManager.sharedDb?.prepare(watchedShows).map({ $0[imdb_id] })
		} catch {
			return nil
		}
	}
	
	public class func toggleWatched(tvdbId : String) {
		if isWatched(tvdbId) {
			remove(tvdbId)
		} else {
			add(tvdbId)
		}
	}
}
