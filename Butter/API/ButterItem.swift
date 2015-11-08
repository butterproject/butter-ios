//
//  ButterItem.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SwiftyJSON

class ButterItem {
    var id: Int
    var properties:[String:AnyObject] = [String:AnyObject]()
    var torrents: [String:ButterTorrent] = [String:ButterTorrent]()
    
    func setProperty(name:String, val:AnyObject) {
        properties[name] = val
    }
    
    func getProperty(name:String) -> AnyObject? {
        return properties[name]
    }
    
    func hasProperty(name: String) -> Bool {
        return getProperty(name) != nil
    }
    
    init(id:Int,torrents: JSON) {
        self.id = id
        if (torrents != "") {
            for (_, subJson) in torrents {
                if let url = subJson["url"].string {
                    let tor = ButterTorrent(
                        url: url,
                        seeds: subJson["seeds"].int!,
                        peers: subJson["peers"].int!,
                        quality: subJson["quality"].string!,
                        size: subJson["size"].string!,
                        hash: subJson["hash"].string!)
                    
                    self.torrents[subJson["quality"].string!] = tor
                }
            }
        }
    }
    
    init(id:Int,torrentURL: String, quality: String, size: String) {
        self.id = id
        let tor = ButterTorrent(
            url: torrentURL,
            seeds: 0,
            peers: 0,
            quality: quality,
            size: size,
            hash: "")
        
        self.torrents[quality] = tor
    }
    
    init(id:Int,torrents: [ButterTorrent]) {
        self.id = id
        for tor in torrents {
            self.torrents[tor.quality] = tor
        }
    }
}
