//
//  Client.swift
//  Virtual Tourist
//
//  Created by Selasi Kudolo on 2020-05-08.
//  Copyright © 2020 Selasi. All rights reserved.
//

import Foundation

class Client {

    struct Auth {
        static var apiKey = ""
    }
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        
        case getPhotosFromLocation(longitude: Double, latitude: Double)
        
        var stringValue: String {
            switch self {
            case .getPhotosFromLocation(let longitude, let latitude):
                let randomPage = Int.random(in: 0..<600)
                return Endpoints.base + "?method=flickr.photos.search&api_key=\(Auth.apiKey)&lat=\(latitude)&lon=\(longitude)&page=\(randomPage)&per_page=30&format=json&nojsoncallback=1"
            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }
    }

    class func getPhotosFromLocation(latitude: Double, longitude: Double, completion: @escaping ([PhotoResponse]?, Error?) -> Void) {
        let url = Endpoints.getPhotosFromLocation(longitude: longitude, latitude: latitude).url
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
           guard let data = data else {
               DispatchQueue.main.async {
                   completion(nil, error)
               }
               return
           }

           let decoder = JSONDecoder()

           do {
               let responseObject = try decoder.decode(FlickrAPIResponse.self, from: data)
               DispatchQueue.main.async {
                completion(responseObject.photos.photo, nil)
               }
           } catch {
               DispatchQueue.main.async {
                   completion(nil, error)
               }
           }
        }

        task.resume()
    }
    
    class func downloadPhotoFromURL(url: String, completion: @escaping (Data?, Error?) -> ()) {
        let photoUrl = URL(string: url)!
        let task = URLSession.shared.dataTask(with: photoUrl) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            completion(data, nil)
        }
        task.resume()
    }
}
