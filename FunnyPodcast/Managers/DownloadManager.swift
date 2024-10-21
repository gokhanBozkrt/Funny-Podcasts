//
//  DownloadManager.swift
//  FunnyPodcast
//
//  Created by Gokhan on 21.10.2024.
//

import Foundation


class DownloadManager: NSObject, URLSessionDelegate,URLSessionDownloadDelegate {
 

    var episode: Episode?
    public private(set) var downloadProgress: String = ""
    
    private var downloadTask: URLSessionDownloadTask? = nil
    
    private lazy var urlSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: nil
    )

     init(episode: Episode) {
        self.episode = episode
       
    }
   
    func startDownload() {
        
        if let episode {
            
            guard let url = URL(string: episode.streamUrl) else { return }
            
            self.downloadTask = urlSession.downloadTask(with: url)
            guard let downloadTask = downloadTask else { return }
            downloadTask.resume()
            
        }
    }
}


extension DownloadManager {
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        do {
            if downloadTask == self.downloadTask {
                let documentsURL = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )
                
                let savedURL = documentsURL.appendingPathComponent("\(Date()).mp3")
                try FileManager.default.moveItem(at: location, to: savedURL)
                
                UserDefaults.updateDownloadedURL(for: episode!, location: savedURL)
                
            }
    } catch {
        print("Error: \(error)")
    }
        
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        
        if downloadTask == self.downloadTask {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                downloadProgress = String(format: "%.2f%%", progress * 100)
                print("Download Progress: \(downloadProgress)")
            }
            
        }
        
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: (any Error)?
    ) {
    }
}
