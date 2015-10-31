//
//  ButterTorrent.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation

enum THealth {
    case bad
    case medium
    case good
    case excellent
    case unknown
}

class ButterTorrent {
    var seeds, peers: Int
    var url, quality, size, hash: String
    var health: THealth = .unknown
    
    init(url:String, seeds:Int, peers:Int, quality:String, size:String, hash:String) {
        self.url = url
        self.seeds = seeds
        self.peers = peers
        
        self.quality = quality
        self.size = size
        self.hash = hash
        
        calcHealth()
    }
    
    func calcHealth() {
        let seeds = self.seeds
        let peers = self.peers
        
        // First calculate the seed/peer ratio
        let ratio = peers > 0 ? (seeds / peers) : seeds
        
        // Normalize the data. Convert each to a percentage
        // Ratio: Anything above a ratio of 5 is good
        let normalizedRatio = min(ratio / 5 * 100, 100)
        // Seeds: Anything above 30 seeds is good
        let normalizedSeeds = min(seeds / 30 * 100, 100)
        
        // Weight the above metrics differently
        // Ratio is weighted 60% whilst seeders is 40%
        let weightedRatio = Double(normalizedRatio) * 0.6
        let weightedSeeds = Double(normalizedSeeds) * 0.4
        let weightedTotal = weightedRatio + weightedSeeds
        
        // Scale from [0, 100] to [0, 3]. Drops the decimal places
        var scaledTotal = ((weightedTotal * 3.0) / 100.0)// | 0.0
        if (scaledTotal < 0) {
            scaledTotal = 0
        }
        
        //println(floor(scaledTotal))
        
        switch floor(scaledTotal) {
        case 0:
            self.health = .bad
            break
        case 1:
            self.health = .medium
            break
        case 2:
            self.health = .good
            break
        case 3:
            self.health = .excellent
            break
        default:
            self.health = .unknown
            break
        }
    }
}
