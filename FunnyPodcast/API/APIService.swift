//
//  APIService.swift
//  FunnyPodcast
//
//  Created by Gökhan Bozkurt on 8.05.2024.
//

import Alamofire
import FeedKit
import Foundation

class APIService {
    
    static let shared = APIService()
    
    private init() { }
    
    let baseiTunesSearchUrl = "https://itunes.apple.com/search"
    
    func fetchEpisodes(for feedUrlString: String, complitionHandler: @escaping ([Episode]) -> ()) {
        
        guard let feedUrl = URL(string: feedUrlString) else { return }
        
        let parser = FeedParser(URL: feedUrl)
        parser.parseAsync(queue: DispatchQueue.global(qos: .utility)) { (result) in
                switch result {
                case .success(let feed):
                    switch feed {
                    case let .rss(feed):
                        complitionHandler(feed.toEpisodes())
                        break
                    default:
                        break
                    }
                case .failure(let error):
                    print("XML parse error",error)
                }
            
        }
    }
    
    func fetchPodCast(for searchText: String,completionHandler: @escaping ([Podcast]) -> ()) {
        
        let parameters = ["term" : searchText,"media" : "podcast"]
        
        AF.request(baseiTunesSearchUrl, method: .get, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: nil).responseData { dataResponse in
            if let error = dataResponse.error {
                print("Error",error)
                return
            }
            
            guard let data = dataResponse.data else { return }
           
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                completionHandler(searchResult.results)
                            
            } catch {
                print("Failed to decode",error.localizedDescription)
            }
            
        }
    }
}
