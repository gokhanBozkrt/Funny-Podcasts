//
//  DownloadsController.swift
//  FunnyPodcast
//
//  Created by Gokhan on 20.10.2024.
//

import UIKit

class DownloadsController: UITableViewController {

   private let cellId = "cellId"
    
    var episodes: [Episode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupObservers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.episodes = UserDefaults.getDownloadedEpisodes()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgressNotification, object: nil)
    }
    
    @objc private func handleDownloadProgress(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        
        let progress = userInfo["progress"] as? String
        let episodeTitle = userInfo["title"] as? String
        
        guard let index = self.episodes.firstIndex(where: { $0.title == episodeTitle }) else { return }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        UIView.animate(withDuration: 1) {
            cell.progressLabel.text = progress

        }
        cell.progressLabel.isHidden = false
        
        if progress == "100.00%" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.animate(withDuration: 1) {
                    cell.progressLabel.isHidden = true
                }
            }
        }
    }
}


extension DownloadsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 134
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        
        if episode.downloadedURL != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode,playlistEpisodes: episodes)
        }
    }
}
