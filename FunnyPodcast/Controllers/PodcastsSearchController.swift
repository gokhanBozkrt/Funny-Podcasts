//
//  PodcastsSearchController.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 1.04.2024.
//

import UIKit

class PodcastsSearchController: UITableViewController {
    
    var podcasts = [Podcast]()
    
    let cellID = "cellid"
    
    var timer: Timer?
    var isSearching = false
  
        
    var spinner: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .darkGray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        configureActivityIndicator()
    }
    
    func configureActivityIndicator() {
        view.addSubview(spinner)
   
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 30),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
           
        ])
    }
    
    fileprivate func setupSearchBar() {
//        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
    }
    
    fileprivate func setupTableView() {
     
        let nib = UINib(nibName: "PodCastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        podcasts.count
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        115
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Search for podcasts all over the world."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  self.podcasts.isEmpty  ?  250 : 0
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let podcast = podcasts[indexPath.row]
        let episodesController = EpisodeController()
        episodesController.podcast = podcast
        navigationController?.pushViewController(episodesController, animated: true)
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PodCastCell
        
        let podcast = podcasts[indexPath.row]
        cell.podcast = podcast
        
//        if #available(iOS 14.0, *) {
//            var content = cell.defaultContentConfiguration()
//            content.image = UIImage(named: "podpicture")
//            content.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
//            content.textProperties.numberOfLines = -1
//            cell.contentConfiguration = content
//        } else {
//            cell.textLabel?.text = "\(podcast.trackName ?? "")\n\(podcast.artistName ?? "")"
//            cell.textLabel?.numberOfLines = -1
//            cell.imageView?.image = UIImage(named: "podpicture")!
//
//        }
        return cell
    }
    
}



extension PodcastsSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearching = true
        if self.podcasts.isEmpty {
            spinner.startAnimating()
        }
       
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
          
            APIService.shared.fetchPodCast(for: searchText) { podcasts in
                self.podcasts = podcasts
                self.spinner.stopAnimating()
                self.isSearching = false
                self.tableView.reloadData()
            }
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.podcasts.removeAll(keepingCapacity: false)
        self.tableView.reloadData()
    }
    

}
