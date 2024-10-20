//
//  CMTime+Extension.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 13.05.2024.
//

import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let hourMinute = minutes % 60
        let hour = minutes / 60
        let timeFormatString = hour > 0 ? String(format: "%02d:%02d:%02d", hour,hourMinute,seconds) : String(format: "%02d:%02d", minutes,seconds)
        return timeFormatString
    }
}
