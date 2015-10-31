//
//  MovieAPI.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SwiftyJSON

class MovieAPI {
    static let sharedInstance = MovieAPI()
    
    let APIManager: ButterAPIManager = ButterAPIManager.sharedInstance
	
	static let genres = [
		"All",
		"Action",
		"Adventure",
		"Animation",
		"Biography",
		"Comedy",
		"Crime",
		"Documentary",
		"Drama",
		"Family",
		"Fantasy",
		"Film-Noir",
		"History",
		"Horror",
		"Music",
		"Musical",
		"Mystery",
		"Romance",
		"Sci-Fi",
		"Short",
		"Sport",
		"Thriller",
		"War",
		"Western"
	]
	
	func load(page: Int, onCompletion: (newItems : Bool) -> Void) {
        //Build the query
		
        var urlParams = [
            "limit" : "\(APIManager.amountToLoad)",
            "page" : "\(page)",
            "sort_by" : "seeds",
            "query_term" : "\(APIManager.searchString)",
            "quality" : "\(APIManager.quality)",
            "lang" : "\(NSLocale.get2LetterLanguageCode())"
        ]
		
		var genreStringForUrl = ""
		for genre in APIManager.genres {
			if genreStringForUrl == "" {
				genreStringForUrl += genre
			} else {
				genreStringForUrl += "&genre[]=\(genre)"
			}
		}
		urlParams["genre[]"] = genreStringForUrl
				
        let headers = [
            "Host" : APIManager.moviesAPIEndpointCloudFlareHost
        ]
		
        RestApiManager.sharedInstance.getJSONFromURL(APIManager.moviesAPIEndpoint + "list_movies_pct.json", headers: headers, parameters: urlParams)  { json in
            
			let movies = json["data","movies"]
            for (_, movie) in movies {
                
                if !self.APIManager.isSearching {
                    if let _ = self.APIManager.cachedMovies[movie["imdb_code"].string!] { //Check it hasn't already been loaded
                        if let iteID = movie["id"].int {
                            if (movie["state"].string == "ok") { //Check that the movie is OK
                                let ite: ButterItem = ButterItem(id: iteID, torrents: movie["torrents"])
                                ite.setProperty("title", val: movie["title"].string!)
                                let title = ite.getProperty("title") as! String!
                                print("Duplicate movie: \(title) - From page: \(page + 1)")
                                continue
                            }
                        }
                    }
                }
                
                if let iteID = movie["id"].int {
                    if (movie["state"].string == "ok") { //Check that the movie is OK
                        self.createMovieFromJson(iteID, movie)
                    }
                }
            }
			
            onCompletion(newItems: movies.count > 0)
        }
    }
    
	func getMovie(id: String, onCompletion: (loadedFromCache : Bool) -> Void) {
        //Request the data from the API
        if let _ = self.APIManager.cachedMovies[id] {
            //print("Movie already cached")
            onCompletion(loadedFromCache: true)
        } else {
            let URL = NSURL(string: APIManager.moviesAPIEndpoint + "list_movies_pct.json?query_term=\(id)&limit=1&lang=\(NSLocale.get2LetterLanguageCode())")
			let mutableURLRequest = NSMutableURLRequest(URL: URL!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0 as NSTimeInterval!)
			mutableURLRequest.setValue(APIManager.moviesAPIEndpointCloudFlareHost, forHTTPHeaderField: "Host")
			mutableURLRequest.HTTPMethod = "GET"
			
            RestApiManager.sharedInstance.getJSONFromURL(mutableURLRequest) { json in
                let movie = json["data","movies",0]
                if (json["status"].string == "ok") {
                    if let iteID = movie["id"].int {
                        self.createMovieFromJson(iteID, movie)
                    }
                }
                
                onCompletion(loadedFromCache: false)
            }
        }
    }
    
    func createMovieFromJson(id : Int, _ json : JSON) -> ButterItem {
        let ite: ButterItem = ButterItem(id: id, torrents: json["torrents"])
        ite.setProperty("title", val: json["title"].string!)
        ite.setProperty("description", val: json["description_full"].string!)
        ite.setProperty("rating", val: json["rating"].double!)
        ite.setProperty("imdb", val: json["imdb_code"].string!)
        ite.setProperty("year", val: json["year"].int!)
        ite.setProperty("runtime", val: json["runtime"].int!)
        ite.setProperty("coverURL", val: json["medium_cover_image"].string!)
        
        var genres: String = ""
        for (index, subJson) in json["genres"] {
            if (index != "0") {
                genres += ", \(subJson.string!)"
            } else {
                genres += subJson.string!
            }
        }
        ite.setProperty("genres", val: genres)
        
        if (self.APIManager.isSearching) {
            self.APIManager.searchResults[json["imdb_code"].string!] = ite
        } else {
            self.APIManager.cachedMovies[json["imdb_code"].string!] = ite
        }
        
        RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String, onCompletion: { image in
            ite.setProperty("cover", val: image)
        })
        
        return ite
    }
}