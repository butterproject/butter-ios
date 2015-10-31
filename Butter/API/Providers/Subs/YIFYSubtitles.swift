//
//  YIFYSubtitles.swift
//  Butter
//
//  Created by Moorice on 15-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import Foundation
import SwiftyJSON

class YIFYSubtitles {
	static let apiEndpoint = "http://api.yifysubtitles.com/subs/"
	static let sharedInstance = YIFYSubtitles()
	
	func getSubtitle(imdb_id : String, onCompletion: ([String : String]) -> Void) {
		let parameters = ["type" : "movie"]
		RestApiManager.sharedInstance.getJSONFromURL(YIFYSubtitles.apiEndpoint + imdb_id, parameters: parameters) { (json) in
			
			var subtitleURLPerLanguage = [String : String]()
			
			if let _ = json["success"].bool {
				// Loop subtitle languages
				for (lang, subs) in json["subs"][imdb_id] {
					// Loop known languages in app
					for (_, knownLangFull) in ButterAPIManager.languages {
						if lang == knownLangFull.lowercaseString {
							var bestSub : JSON?
							// Find best rated subtitles
							for (_, subsForLang) in subs {
								if let rating = subsForLang["rating"].int {
									if bestSub != nil {
										if let ratingBest = bestSub!["rating"].int {
											// Override bestSub when rating > current best rating
											if rating > ratingBest {
												bestSub = subsForLang
											}
										}
									} else {
										// Set current sub automatically to best sub when no bestSub is set
										bestSub = subsForLang
									}
								}
							}
							
							if let bestSub = bestSub {
								subtitleURLPerLanguage[bestSub["url"].string!] = knownLangFull
							}

							break
						}
					}
				}
			}
			
			onCompletion(subtitleURLPerLanguage)
		}
	}
}