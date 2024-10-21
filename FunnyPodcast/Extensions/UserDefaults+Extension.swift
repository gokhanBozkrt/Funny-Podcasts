//
//  UserDefaults+Extension.swift
//  FunnyPodcast
//
//  Created by Gokhan on 30.09.2024.
//

import Foundation

extension UserDefaults {
    
    static let favouritedPodcastKey = "favouritedPodcastKey"
    static let downloadEpisodeKey = "downloadEpisodeKey"

    static func downloadEpisode(episode: Episode) {
        let encoder = JSONEncoder()
        
        var downloadedEpisodes = getDownloadedEpisodes()
        
        if downloadedEpisodes.contains(where: { $0.title == episode.title && $0.author == episode.author }) == false {
            
            downloadedEpisodes.insert(episode, at: 0)
            
            do {
                let data = try encoder.encode(downloadedEpisodes)
                
                UserDefaults.standard.set(data, forKey: UserDefaults.downloadEpisodeKey)
            } catch {
                print("Encode Error")
            }
        }
    }
    
    static func getDownloadedEpisodes() -> [Episode] {
        
        var episodes: [Episode] = []
        
        let data = UserDefaults.standard.data(forKey: UserDefaults.downloadEpisodeKey)
        
        do {
            guard let data = data else { return  episodes}
            
            let decoder = JSONDecoder()
             episodes = try decoder.decode([Episode].self, from: data)
            return episodes
        } catch {
            print("Decode Error")
        }
        return episodes
    }
    
    static func updateDownloadedURL(for episode: Episode,location: URL) {
        
        var downloadedEpisodes = getDownloadedEpisodes()
        
        guard let index = downloadedEpisodes.firstIndex(where: {$0.title == episode.title && $0.author == episode.author }) else { return }
        downloadedEpisodes[index].downloadedURL = location
        
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(downloadedEpisodes)
            
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadEpisodeKey)
        } catch {
            print("Encode Error")
        }
        
    }
    
    static func getSavedPodcasts() -> [Podcast]? {
        
         let fetchedValue = UserDefaults.standard.data(forKey: UserDefaults.favouritedPodcastKey)
        
        guard let fetchedValue = fetchedValue else { return nil }

        
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: fetchedValue)
            unarchiver.requiresSecureCoding = false
            
            guard let unarchivedPodcasts = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [Podcast]  else { return nil }
            
            return unarchivedPodcasts
                    
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    static func deleteSavedPodcasts(podcasts: [Podcast]) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: podcasts, requiringSecureCoding: false)
            
            UserDefaults.standard.setValue(data, forKey: UserDefaults.favouritedPodcastKey)
        } catch {
            print(error.localizedDescription)
        }
    }
}
