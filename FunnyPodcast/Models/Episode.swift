//
//  Episode.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 8.05.2024.
//

import FeedKit
import Foundation

struct Episode: Identifiable,Codable {
    var id = UUID()
    let title: String
    let pubDate: Date
    let description: String
    var imageUrl: String?
    var author: String
    let streamUrl: String
    var downloadedURL: URL?
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
    }
}
