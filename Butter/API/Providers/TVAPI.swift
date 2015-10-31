//
//  TVAPI.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SwiftyJSON

class TVAPI {
    static let sharedInstance = TVAPI()
    
    let APIManager: ButterAPIManager = ButterAPIManager.sharedInstance
	
	static let genres = [
		"All",
		"Action",
		"Adventure",
		"Animation",
		"Children",
		"Comedy",
		"Crime",
		"Documentary",
		"Drama",
		"Family",
		"Fantasy",
		"Game Show",
		"Home and Garden",
		"Horror",
		"Mini Series",
		"Mystery",
		"News",
		"Reality",
		"Romance",
		"Science Fiction",
		"Soap",
		"Special Interest",
		"Sport",
		"Suspense",
		"Talk Show",
		"Thriller",
		"Western"
	]
	
	func load(page: Int, onCompletion: (newItems : Bool) -> Void) {
        //Build the query
		
        let urlParams = [
            "sort" : "seeds",
            "limit" : "\(APIManager.amountToLoad)",
            "genre" : APIManager.genres[0],
            "order" : "-1",
            "keywords" : APIManager.searchString,
        ]
        
        //Request the data from the API
        RestApiManager.sharedInstance.getJSONFromURL("\(APIManager.TVShowsAPIEndpoint)\(page)", parameters: urlParams) { json in
            let shows = json
            for (_, show) in shows {
                if !self.APIManager.isSearching {
                    if let _ = self.APIManager.cachedTVShows[show["imdb_id"].string!] { //Check it hasn't already been loaded
                        continue
                    }
                }
                
                if let iteID = show["tvdb_id"].string {
                    self.createShowFromJson(iteID, show)
                }
            }
            
            onCompletion(newItems: shows.count > 0)
        }
    }
	
	func getShow(id: String, onCompletion: (loadedFromCache : Bool) -> Void) {
		let URL = NSURL(string: "http://eztvapi.re/show/\(id)")
		let mutableURLRequest = NSMutableURLRequest(URL: URL!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 as NSTimeInterval!)
		mutableURLRequest.HTTPMethod = "GET"
		
		if let _ = self.APIManager.cachedTVShows[id] {
			onCompletion(loadedFromCache: true)
		} else {
			RestApiManager.sharedInstance.getJSONFromURL(mutableURLRequest) { json in
				self.createShowFromJson(json["tvdb_id"].string!, json)
				onCompletion(loadedFromCache: false)
			}
		}
	}
	
	func createShowFromJson(tvdb_id : String, _ json : JSON) -> ButterItem {
		let ite: ButterItem = ButterItem(id: Int(tvdb_id)!, torrents: JSON(""))
		ite.setProperty("title", val: json["title"].string!)
		ite.setProperty("imdb", val: json["imdb_id"].string!)
		ite.setProperty("year", val: json["year"].string!)
		ite.setProperty("seasons", val: json["num_seasons"].int!)
		
        if (self.APIManager.isSearching) {
            self.APIManager.searchResults[json["imdb_id"].string!] = ite
        } else {
            self.APIManager.cachedTVShows[json["imdb_id"].string!] = ite
        }
		
		ite.setProperty("coverURL", val: json["images","poster"].string!.stringByReplacingOccurrencesOfString("original", withString: "thumb", options: .LiteralSearch, range: nil))
		RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String, onCompletion: { image in
			ite.setProperty("cover", val: image)
		})
		
		ite.setProperty("fanartURL", val: json["images","fanart"].string!)
        
		return ite
	}
	
    func requestShowInfo(imdb: String, onCompletion: () -> Void) {
        let imdbURL = "http://eztvapi.re/show/\(imdb)"
        let url = NSURL(string:imdbURL)
        print(url)
        let mutableURLRequest = NSMutableURLRequest(URL: url!)
        mutableURLRequest.HTTPMethod = "GET"
		
        let ite: ButterItem?
        if (self.APIManager.isSearching) {
            ite = ButterAPIManager.sharedInstance.searchResults[imdb]!
        } else {
            ite = ButterAPIManager.sharedInstance.cachedTVShows[imdb]!
        }
		
		// Download fanart
		if ite!.hasProperty("fanartURL") {
			RestApiManager.sharedInstance.loadImage(ite!.getProperty("fanartURL") as! String, onCompletion: { image in
				ite!.setProperty("fanart", val: image)
				onCompletion()
			})
		}
		
		// Load show info
        RestApiManager.sharedInstance.getJSONFromURL(mutableURLRequest) { json in
			
            if let episodes: JSON? = json["episodes"] {
                var showSeasons : [Int:[ButterItem]] = [Int:[ButterItem]]()
				
                for (_, episode) in episodes! {
                    var episodeTorrents: [ButterTorrent] = [ButterTorrent]()
                    for (name, torr) in episode["torrents"] {
                        if (name == "0") {
                        } else {
                            let quTor: ButterTorrent = ButterTorrent(url: torr["url"].string!, seeds: torr["seeds"].int!, peers: torr["peers"].int!, quality: name, size: "", hash: "")
                            episodeTorrents.append(quTor)
                        }
                    }

					let ep = ButterItem(id: episode["tvdb_id"].int!, torrents: episodeTorrents)
                    ep.setProperty("season", val: episode["season"].int!)
                    ep.setProperty("episode", val: episode["episode"].int!)
                    
                    if let desc = episode["overview"].string {
                        ep.setProperty("description", val: desc)
                    } else {
                        let desc = "Synopsis Not Available"
                        ep.setProperty("description", val: desc)
                    }
                    if let title = episode["title"].string {
                        ep.setProperty("title", val: title)
                    } else {
						
						let episode = episode["episode"].int!
						ep.setProperty("title", val: "Episode \(episode)")
						
						// TODO: Uncomment when Xcode 7.1 is released: http://stackoverflow.com/questions/24024754/escape-dictionary-key-double-quotes-when-doing-println-dictionary-item-in-swift
						//ep.setProperty("title", val: "Episode \(episode["episode"].int!)")
						
                    }
                    ep.setProperty("first_aired", val: episode["first_aired"].int!)
                    if let _ = showSeasons[episode["season"].int!] {
                        var seasonEpisodes = showSeasons[episode["season"].int!]
                        seasonEpisodes!.append(ep)
                        showSeasons[episode["season"].int!] = seasonEpisodes
                    } else {
                        showSeasons[episode["season"].int!] = [ep]
                    }
                }
                ite!.setProperty("seasons", val: showSeasons)
            }
            
            if let rating = json["rating","percentage"].int {
				let ratingFloat = Float(rating)
                ite!.setProperty("rating", val: (ratingFloat/100)*5)
            }
            
            if json["network"].string != nil {
                ite!.setProperty("network", val: json["network"].string!)
            }
            
            if json["air_day"].string != nil {
                ite!.setProperty("air_day", val: json["air_day"].string!)
            }
            if json["air_time"].string != nil {
                ite!.setProperty("air_time", val: json["air_time"].string!)
            }
            
            if let runtime = json["runtime"].string {
                ite!.setProperty("runtime", val: Int(runtime)!)
            }
            
            if json["status"].string != nil {
                ite!.setProperty("status", val: json["status"].string!)
            }
            
            if json["synopsis"].string != nil {
                ite!.setProperty("description", val: json["synopsis"].string!)
            }
            
            var genres: String = ""
            for (index, subJson) in json["genres"] {
                if (index != "0") {
                    genres += ", \(subJson.string!)"
                } else {
                    genres += subJson.string!
                }
            }
            ite!.setProperty("genres", val: genres)
            
            onCompletion()
        }
    }
}