//
//  AnimeAPI.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation

class AnimeAPI {
    static let sharedInstance = AnimeAPI()
    
    let APIManager: ButterAPIManager = ButterAPIManager.sharedInstance
    
    func load(page: Int, onCompletion: () -> Void) {
        
        RestApiManager.sharedInstance.getJSONFromURL(APIManager.animeAPIEndpoint, parameters: [ "sort": "popularity",
                                                                        "limit": APIManager.amountToLoad,
                                                                        "type": "All",
                                                                        "page": page,
                                                                        "order": "asc",
                                                                        "search": APIManager.searchString]) { json in
        
            let Animes = json
            for (_, Anime) in Animes {
                if let iteID = Anime["id"].int {
                    let ite: ButterItem = ButterItem(id: iteID, torrents: "")
                    ite.setProperty("title", val: Anime["name"].string!)
                    ite.setProperty("episodes", val: Anime["numep"].int!)
                    ite.setProperty("type", val: Anime["type"].string!)
                    ite.setProperty("coverURL", val: Anime["malimg"].string!)
                    
                    self.APIManager.cachedAnime["\(iteID)"] = ite
                    
                    RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String, onCompletion: { image in
                        ite.setProperty("cover", val: image)
                    })
                }
            }
            onCompletion()
        }
    }
}