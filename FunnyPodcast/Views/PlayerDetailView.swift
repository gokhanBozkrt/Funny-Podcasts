//
//  PlayersDetailView.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 10.05.2024.
//

import AVKit
import UIKit
import MediaPlayer
import SDWebImage

/*
 CMTime t1 = CMTimeMake(1, 10); // 1/10 second = 0.1 second
 CMTime t2 = CMTimeMake(2, 1);  // 2 seconds
 CMTime t3 = CMTimeMake(3, 4);  // 3/4 second = 0.75 second
 CMTime t4 = CMTimeMake(6, 8);  // 6/8 second = 0.75 second


 So Brians example will run the block of code, enlarge the image, 0.3 seconds after the audio started playing.
 */

class PlayerDetailView: UIView {
    
    var episode: Episode! {
        didSet {
            episodeTitle.text = episode.title
            miniTitleLabel.text = episode.title
            authorTitleLabel.text = episode.author
            let url = URL(string: episode.imageUrl?.toSecureHttps() ?? "")
            episodeImageView.sd_setImage(with: url, placeholderImage: nil)
            miniEpisodeImageView.sd_setImage(with: url, placeholderImage: nil) { image,_,_,_ in
                
                guard let image = image else{ return }
                    
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                    return image
                }
                
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    
            }
            setupAudioSession()
            playEpisode()
            setupRemoteControlSettings()
            
        }
    }
    
    var playlistEpisodes = [Episode]()
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = true
        return avPlayer
    }()
    
    var panGesture: UIPanGestureRecognizer!
    
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    
    @IBOutlet weak var miniPlayerView: UIView!
    
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    
    @IBOutlet weak var miniTitleLabel: UILabel!
    
    @IBOutlet weak var miniPlayAndPauseButton: UIButton! {
        didSet {
            miniPlayAndPauseButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            miniPlayAndPauseButton.setImage(.play, for: .normal)
            miniPlayAndPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    
    @IBOutlet weak var miniFastForwardButton: UIButton! {
        didSet {
            miniFastForwardButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            miniFastForwardButton.addTarget(self, action: #selector(handleFastForward), for: .touchUpInside)

        }
    }
    
    
    @IBAction func handleDismiss(_ sender: Any) {
//        self.removeFromSuperview()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate
          else {
            return
          }
        
       let mainTabbarController =  sceneDelegate.window?.rootViewController as? MainTabBarController
        mainTabbarController?.minimizePlayerDetails()
        
    }
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            let scale: CGFloat = 0.5
            
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            
            episodeImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    @IBOutlet weak var episodeTitle: UILabel! {
        didSet {
            episodeTitle.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var authorTitleLabel: UILabel!
    

    @IBOutlet weak var currentTimeLabel: UILabel!
    
    
    @IBOutlet weak var durationLabel: UILabel!
    
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
        
    @IBOutlet weak var currentTimeSlider: UISlider!
    
    
    @IBAction func currentTimeSliderChange(_ sender: UISlider) {
        
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.asset.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
            
        self.player.seek(to: seekTime)
    }
    
    
    @IBAction func handleRewind(_ sender: Any) {
        let fifteenSeconds = CMTimeMake(value: -15, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        self.player.seek(to: seekTime)
    }
    
    @IBAction func handleForward(_ sender: Any) {
        let fifteenSeconds = CMTimeMake(value: 15, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        self.player.seek(to: seekTime)
    }
    
    @IBAction func handleValumeChanged(_ sender: UISlider) {
        player.volume = sender.value
        
    }
    
    fileprivate func observeBoundaryTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {  [weak self] in
            guard let self = self else { return }
            enlargeEpisodeImageView()
            setupLockScreenDuration()
        }
    }
    
    
    fileprivate func setupLockScreenDuration() {
        guard let duration = player.currentItem?.duration else { return }
        
        let durationInSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteControl()
        setInterruptionsObserver()
        observePlayerCurrentTime()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
        
        observeBoundaryTime()
    }
    
    fileprivate func setInterruptionsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            playPauseButton.setImage(.play, for: .normal)
            miniPlayAndPauseButton.setImage(.play, for: .normal)

        } else {
            
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playPauseButton.setImage(.pause, for: .normal)
                miniPlayAndPauseButton.setImage(.pause, for: .normal)
            }
        }

        
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
      
        if gesture.state == .began {
            
        } 
        else if gesture.state == .changed {
       handlePanChanged(gesture: gesture)
            
        } else if gesture.state == .ended {
            handlePanEnded(gesture: gesture)
        }
    }
    
    func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1,options: .curveEaseOut) {
            self.transform = .identity
            
            if translation.y < -200 || velocity.y < -500 {
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let sceneDelegate = windowScene.delegate as? SceneDelegate
                  else {
                    return
                  }
                
               let mainTabbarController =  sceneDelegate.window?.rootViewController as? MainTabBarController
                mainTabbarController?.maximizePlayerDetails(episode: nil)
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
        }
    }
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1,options: .curveEaseInOut) {
                self.maximizedStackView.transform = .identity
                
                if translation.y > 80 {
                    
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let sceneDelegate = windowScene.delegate as? SceneDelegate
                      else {
                        return
                      }
                    
                    let mainTabbarController =  sceneDelegate.window?.rootViewController as? MainTabBarController
                     mainTabbarController?.minimizePlayerDetails()
                }
            }
        }
    }
    
    @objc func handleTapMaximize() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate
          else {
            return
          }
        
       let mainTabbarController =  sceneDelegate.window?.rootViewController as? MainTabBarController
        mainTabbarController?.maximizePlayerDetails(episode: nil)
    }
    
    static func initFromNib() -> PlayerDetailView {
        return Bundle.main.loadNibNamed("PlayerDetailView", owner: self)?.first as! PlayerDetailView
    }
    
    fileprivate func  observePlayerCurrentTime() {
        
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self]  time in
            guard let self = self else { return }
            currentTimeLabel.text = time.toDisplayString()
            let totalTime = self.player.currentItem?.asset.duration
            self.durationLabel.text = totalTime?.toDisplayString()
            updateCurrentTimeSlider()
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds =  CMTimeGetSeconds(self.player.currentItem?.asset.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        
        self.currentTimeSlider.value = Float(percentage)
    }
    
    fileprivate func playEpisode() {
        
        var url: URL
        
        if episode.downloadedURL != nil {
            
            let fileName = episode.downloadedURL!.lastPathComponent
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
             url = documentsDirectory.appendingPathComponent(fileName)
      
        } else {
            guard let streamURL = URL(string: episode.streamUrl) else { return }
            url = streamURL
            print("play on the net")
        }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    }
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.episodeImageView.transform = .identity
        }

    }
    
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.episodeImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
    }
    
    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)

        } catch let sessionError {
            print(sessionError)
        }
    }
    
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        setupRemoteControlSettings()
        
        commandCenter.playCommand.addTarget {  (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }

        commandCenter.pauseCommand.addTarget {  (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget {  (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handleNextTrack()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePreviousTrack()
            return .success
        }
    }
    
    fileprivate func handlePreviousTrack() {
        
        let currenEpisodeIndex = playlistEpisodes.firstIndex(where:  { $0.title == episode.title })
        
        if let currenEpisodeIndex {
            
            let previousEpisode: Episode
            
            if currenEpisodeIndex == 0  {
                previousEpisode =  playlistEpisodes[0]
                
            } else {
                previousEpisode = playlistEpisodes[currenEpisodeIndex - 1]

            }
            
            self.episode = previousEpisode

            
        }
        
    }
    
    fileprivate func handleNextTrack() {
    
     guard playlistEpisodes.count > 0 else { return }
     
    let currenEpisodeIndex = playlistEpisodes.firstIndex(where:  { $0.title == episode.title })
     
     if let currenEpisodeIndex {
         
         let nextEpisode: Episode
         
         if currenEpisodeIndex != (playlistEpisodes.count - 1)  {
             nextEpisode =  playlistEpisodes[0]
             
         } else {
             nextEpisode = playlistEpisodes[currenEpisodeIndex + 1]

         }
         
         self.episode = nextEpisode

     }
     
    }
    
    fileprivate func setupElapsedTime(playBackTime: Float) {
    
        
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playBackTime

    }
    
    fileprivate func setupRemoteControlSettings() {
        let infoCenter = MPNowPlayingInfoCenter.default()
        var currentPlayingInfo = infoCenter.nowPlayingInfo ?? [String: Any]()
        
        guard episode != nil else { return }
        
        let title = episode.title
        let author = episode.author
      
        currentPlayingInfo[MPMediaItemPropertyTitle] = title
        currentPlayingInfo[MPMediaItemPropertyArtist] = author
        infoCenter.nowPlayingInfo = currentPlayingInfo
    }
    
    @objc func handlePlayPause() {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(.pause, for: .normal)
            miniPlayAndPauseButton.setImage(.pause, for: .normal)
            self.setupElapsedTime(playBackTime: 1)

            enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(.play, for: .normal)
            miniPlayAndPauseButton.setImage(.play, for: .normal)
            shrinkEpisodeImageView()
            self.setupElapsedTime(playBackTime: 0)

        }
    }
    
    @objc func handleFastForward() {
        let fifteenSeconds = CMTimeMake(value: 15, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        self.player.seek(to: seekTime)
    }
    
}
