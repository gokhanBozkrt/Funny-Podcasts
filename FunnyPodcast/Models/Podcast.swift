//
//  Podcast.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 1.04.2024.
//

import Foundation

class Podcast: NSObject,NSCoding,Decodable {
        
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
    
    func encode(with coder: NSCoder) {
        
        coder.encode(trackName ?? "", forKey: "trackNameKey")
        coder.encode(artistName ?? "", forKey: "artistNameKey")
        coder.encode(artworkUrl600 ?? "", forKey: "artworkUrl600Key")
       

    }
    
    required init?(coder: NSCoder) {
        self.trackName = coder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = coder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl600 = coder.decodeObject(forKey: "artworkUrl600Key") as? String

    }
    
}
