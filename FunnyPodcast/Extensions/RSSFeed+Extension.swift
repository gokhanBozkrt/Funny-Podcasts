//
//  RSSFeed+Extension.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 9.05.2024.
//

import FeedKit


extension RSSFeed {
    func toEpisodes() -> [Episode] {
        var episodes = [Episode]()
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        items?.forEach({ feeditem in
            var episode = Episode(feedItem: feeditem)
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            episodes.append(episode)
        })
        return episodes
    }
}
