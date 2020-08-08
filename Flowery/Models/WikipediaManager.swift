//
//  WikipediaManager.swift
//  Flowery
//
//  Created by Artem Tkachuk on 8/7/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import Foundation

//MARK: - WikipediaManagerDelegate
protocol WikipediaManagerDelegate {
    func didUpdateWikipediaInfo(_ wikipediaManager: WikipediaManager, _ flowerInfo: FlowerModel)
    func didFailWithError(_ error: Error)
}

//MARK: - WikipediaManager()
struct WikipediaManager {
    
    let wikipediaBaseURL = "https://en.wikipedia.org/w/api.php?"
    
    var delegate: WikipediaManagerDelegate?

    //MARK: - getFlowerInfo()
    func getFlowerInfo(for flowerName: String) {
        guard let urlEncodedFlowerName = flowerName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            fatalError("Failed to convert the URL to percent-encoded format")
        }
        
        let urlString = wikipediaBaseURL + createURLParametersString(for: urlEncodedFlowerName)
        performRequest(with: urlString)
    }
    
    //MARK: - createURLString()
    private func createURLParametersString(for urlEncodedFlowerName: String) -> String {
        var urlString = ""
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts%7Cpageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles": urlEncodedFlowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize": "500"
        ]
    
        for (key, value) in parameters {
            urlString += "\(key)=\(value)&"
        }
        
        return urlString
    }
    
    //MARK: - performRequest()
    private func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else {
            print(urlString)
            fatalError("Could not create a URL")
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.delegate?.didFailWithError(error!)
                return
            } else {
                if let safeData = data {
                    if let flowerInfo = self.parseJSON(flowerData: safeData) {
                        self.delegate?.didUpdateWikipediaInfo(self, flowerInfo)
                    }
                }
            }
        }
        task.resume()
    }
    
    //MARK: - parseJSON()
    private func parseJSON(flowerData: Data) -> FlowerModel? {
        let decoder = JSONDecoder()

        do {
            let decodedFlowerData = try decoder.decode(FlowerResponseSchema.self, from: flowerData)
            let pageID = decodedFlowerData.query.pageids[0]
            if let flowerPage = decodedFlowerData.query.pages[pageID] {
                print(pageID)
                let extract = flowerPage.extract
                let thumbnail = flowerPage.thumbnail.source
                
                let flowerInfo = FlowerModel(extract, thumbnail)
                return flowerInfo
            }
            
            return nil
        } catch {
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
}
