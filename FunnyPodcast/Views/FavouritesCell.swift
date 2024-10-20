//
//  FavouritesCell.swift
//  FunnyPodcast
//
//  Created by Gokhan on 23.09.2024.
//

import UIKit

class FavouritesCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()
    
    let artistNameLabel: UILabel = {
        let artistNameLabel = UILabel()
        artistNameLabel.font = UIFont.systemFont(ofSize: 13)
        artistNameLabel.textColor = .lightGray
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return artistNameLabel
    }()
    
    
    
    var podcast: Podcast! {
        didSet {
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
            imageView.sd_setImage(with: url, completed: nil)
        }
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   func  setupCell() {
        let stackView = UIStackView(arrangedSubviews: [imageView,nameLabel,artistNameLabel])
       
       stackView.axis = .vertical
       stackView.translatesAutoresizingMaskIntoConstraints = false

       addSubview(stackView)
       
       NSLayoutConstraint.activate([
       
        stackView.topAnchor.constraint(equalTo: topAnchor),
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)

       ])
    }
    
}

#Preview {
    let cell = FavouritesCell()
    cell.artistNameLabel.text = "Adele"
    cell.nameLabel.text = "Hello"
    cell.imageView.image = UIImage(named: "podpicture")
    return cell
}
