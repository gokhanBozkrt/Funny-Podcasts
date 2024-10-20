//
//  String+Extension.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 9.05.2024.
//

import Foundation

extension String {
    func toSecureHttps() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
