//
//  SerachResults.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 8.05.2024.
//

import Foundation

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
