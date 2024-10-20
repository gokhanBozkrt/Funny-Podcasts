//
//  MainTabBarControoler.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 1.04.2024.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    let playerView = PlayerDetailView.initFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        let favouritesController = FavouritesController(collectionViewLayout: layout)
        tabBar.tintColor = .purple
        UINavigationBar.appearance().prefersLargeTitles = true
        viewControllers = [
        generateNavigationController(with: favouritesController, title: "Favourites", image: "play.circle"),
        generateNavigationController(with: PodcastsSearchController(), title: "Search", image: "magnifyingglass"),
        generateNavigationController(with: DownloadsController(), title: "Downloads", image: "arrow.down.square.fill")
        ]
        
        setupPlayerDetailView()
        
    }
    
   @objc func minimizePlayerDetails() {
       
       maximizedTopAnchorConstraint.isActive = false
       bottomAnchorConstraint.constant = view.frame.height
       minimizedTopAnchorConstraint.isActive = true
       
       UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1) {
           self.view.layoutIfNeeded()
           self.tabBar.isHidden = false
           self.playerView.maximizedStackView.alpha = 0
           self.playerView.miniPlayerView.alpha = 1
       }
    }
    
    func maximizePlayerDetails(episode: Episode?,playlistEpisodes: [Episode] = []) {
        
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        if let episode {
            playerView.episode = episode
        }
        
        playerView.playlistEpisodes = playlistEpisodes
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1) {
            self.view.layoutIfNeeded()
            self.tabBar.isHidden = true
            
            self.playerView.maximizedStackView.alpha = 1
            self.playerView.miniPlayerView.alpha = 0
//          "  self.tabBar.transform = CGAffineTransform(translationX: 0, y: 500)
//            self.tabBar.frame.origin.y = self.view.frame.size.height
        }
     }
    
    fileprivate func setupPlayerDetailView() {
        view.insertSubview(playerView, belowSubview: tabBar)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopAnchorConstraint = playerView.topAnchor.constraint(equalTo: view.topAnchor,constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        minimizedTopAnchorConstraint = playerView.topAnchor.constraint(equalTo: tabBar.topAnchor,constant: -64)
        bottomAnchorConstraint =  playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
       
    }
//MARK: -Helper Functinos
    fileprivate func generateNavigationController(with rootVC: UIViewController,title: String,image: String) -> UIViewController {
        
        let navController = UINavigationController(rootViewController: rootVC)
        rootVC.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(systemName: image)
        return navController
    }

}


//extension UITabBarController {
//    open override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//
//        tabBar.layer.masksToBounds = true
//        tabBar.layer.cornerRadius = 12
//        // Choose with corners should be rounded
//        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // top left, top right
//
//        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow" }) {
//            shadowView.frame = tabBar.frame
//        } else {
//            let shadowView = UIView(frame: .zero)
//            shadowView.frame = tabBar.frame
//            shadowView.accessibilityIdentifier = "TabBarShadow"
//            shadowView.backgroundColor = UIColor.white
//            shadowView.layer.cornerRadius = tabBar.layer.cornerRadius
//            shadowView.layer.maskedCorners = tabBar.layer.maskedCorners
//            shadowView.layer.shadowColor = UIColor.red.cgColor
//            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
//            shadowView.layer.shadowOpacity = 0.1
//            shadowView.layer.shadowRadius = 4
//            view.addSubview(shadowView)
//            view.bringSubviewToFront(tabBar)
//        }
//    }
//}

