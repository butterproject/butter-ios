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
		"All"/*,
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
		"Western"*/
	]
	
	func load(page: Int, onCompletion: (newItems : Bool) -> Void) {
        //Build the query
		
        RestApiManager.sharedInstance.getJSONFromURL(APIManager.moviesAPIEndpoint)  { json in
            
			let movies = json["downloads"]
            for (index, movie) in movies {
                
                if !self.APIManager.isSearching {
                    if let _ = self.APIManager.cachedMovies[movie["ImdbCode"].string!] { //Check it hasn't already been loaded
                        let title = movie["MovieTitleClean"].string!
                        print("Duplicate movie: \(title) - From page: \(page + 1)")
                        continue
                    }
                }
                
                self.createMovieFromJson(Int(index)!, movie)
                
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
        let ite: ButterItem = ButterItem(id: id, torrentURL:json["TorrentUrl"].string!, quality:json["Quality"].string!, size:json["Size"].string!)
        ite.setProperty("title", val: json["MovieTitleClean"].string!)
        ite.setProperty("description", val: json["Synopsis"].string!)
        if let tmp = json["MovieRating"].string {
            ite.setProperty("rating", val: Float(tmp)!)
        }
        ite.setProperty("imdb", val: json["ImdbCode"].string!)
        if let tmp = json["MovieYear"].string {
            ite.setProperty("year", val: Int(tmp)!)
        }
        if let tmp = json["Runtime"].string {
            if (tmp != "") {
                ite.setProperty("runtime", val: Int(tmp)!)
            } else {
                ite.setProperty("runtime", val: 0)
            }
        }
        ite.setProperty("coverURL", val: json["CoverImage"].string!)
        ite.setProperty("genres", val: json["Genre"].string!)
        
        if (self.APIManager.isSearching) {
            self.APIManager.searchResults[json["ImdbCode"].string!] = ite
        } else {
            self.APIManager.cachedMovies[json["ImdbCode"].string!] = ite
        }
        
        RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String, onCompletion: { image in
            ite.setProperty("cover", val: image)
        })
        
        return ite
    }
}