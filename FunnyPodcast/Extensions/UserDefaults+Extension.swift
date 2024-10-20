//
//  UserDefaults+Extension.swift
//  FunnyPodcast
//
//  Created by Gokhan on 30.09.2024.
//

import Foundation

extension UserDefaults {
    
    static let favouritedPodcastKey = "favouritedPodcastKey"

    
    
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
