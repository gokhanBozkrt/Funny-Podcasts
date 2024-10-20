//
//  EpisodeController.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 8.05.2024.
//

import UIKit
import SDWebImage


enum FavouritesError {
    case unsaved,unread,decodeError
}


class EpisodeController: UITableViewController {
    
    fileprivate let cellID = "cellid"
        
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisode()
            
        }
    }
    
    var listOfPodcasts = UserDefaults.getSavedPodcasts() ?? [Podcast]()

    
    var favouriteBarButtonItem: UIBarButtonItem?
       
    
    var episodes = [Episode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBarButtons()
    }
    
    fileprivate func setupNavigationBarButtons() {
        
        self.favouriteBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(handleSaveFavourite)
            )
        
        
        
            navigationItem.rightBarButtonItem = favouriteBarButtonItem
        
    }
    
    @objc func handleFetchSavedPodcasts() {
        UserDefaults.getSavedPodcasts()?.forEach({ p in
            print(p.trackName ?? "")
        })
    }
    
    @objc func handleSaveFavourite() {
        
        
        guard let podcast = podcast else { return }
        
        
        if listOfPodcasts.contains(where: { $0.trackName == podcast.trackName && $0.artistName == podcast.artistName }) == false {
            
            listOfPodcasts.append(podcast)
            
            self.favouriteBarButtonItem?.image = UIImage(systemName: "heart.fill")
            
            showBadgeHighlight()
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts, requiringSecureCoding: false)
                
                UserDefaults.standard.setValue(data, forKey: UserDefaults.favouritedPodcastKey)
                
            } catch {
                print(FavouritesError.unsaved)
            }
        } else {
            print("Already saved")
        }
                
       
        
      
    }
    
    private func showBadgeHighlight() {
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = "New"
    }
    
    fileprivate func fetchEpisode() {
        
        guard let feedUrlString = podcast?.feedUrl else { return }
        
        APIService.shared.fetchEpisodes(for: feedUrlString) { episodes in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.episodes = episodes
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    //MARK: UITableView
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
        
        let episode = episodes[indexPath.row]
//        let data = Data(episode.description.utf8)
//
//        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//            cell.episodeDescription.text = attributedString.string
//        }
        
        let url = URL(string: episode.imageUrl?.toSecureHttps() ?? "")
        let scale = UIScreen.main.scale
        let thumbnailSize = CGSize(width: 50 * scale, height: 50 * scale)
        cell.episodeImageView.sd_setImage(with: url, placeholderImage: nil, context: [.imageThumbnailPixelSize : thumbnailSize])
        
        
        cell.episode = episode
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episode = episodes[indexPath.row]
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate
          else {
            return
          }
        
       let mainTabbarController =  sceneDelegate.window?.rootViewController as? MainTabBarController
        mainTabbarController?.maximizePlayerDetails(episode: episode,playlistEpisodes: self.episodes)
//        let episode = episodes[indexPath.row]
//        
//        let window = UIApplication.shared.windows.last { $0.isKeyWindow }
//        let playerDetailView = PlayerDetailView.initFromNib()
//        
//        playerDetailView.episode = episode
//        
//        let url = URL(string: episode.imageUrl?.toSecureHttps() ?? "")
//        playerDetailView.episodeImageView.sd_setImage(with: url, placeholderImage: nil)
// 
//        playerDetailView.frame = view.frame
//        window?.addSubview(playerDetailView)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
   
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0

    }
    
}


