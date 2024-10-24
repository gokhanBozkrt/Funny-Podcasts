//
//  EpisodeCell.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 9.05.2024.
//

import UIKit

class EpisodeCell: UITableViewCell {

    
    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBOutlet weak var pubDateLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var episodeDescription: UILabel! {
        didSet {
            episodeDescription.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var progressLabel: UILabel!
    
    
    
    
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            episodeDescription.text = episode.description
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM,yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            
            let url = URL(string: episode.imageUrl?.toSecureHttps() ?? "")
            let scale = UIScreen.main.scale
            let thumbnailSize = CGSize(width: 50 * scale, height: 50 * scale)
            episodeImageView.sd_setImage(with: url, placeholderImage: nil, context: [.imageThumbnailPixelSize : thumbnailSize])
            
        }
    }
    
    
    
    
    
}
