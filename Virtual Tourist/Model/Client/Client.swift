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
                return Endpoints.base + "?method=flickr.photos.search&api_key=\(Auth.apiKey)&lat=\(latitude)&lon=\(longitude)&per_page=30&format=json&nojsoncallback=1"
            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }
    }

    class func getPhotosFromLocation(latitude: Double, longitude: Double, completion: @escaping (PhotosResponse?, Error?) -> Void) {
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
               let responseObject = try decoder.decode(PhotosResponse.self, from: data)
               DispatchQueue.main.async {
                   completion(responseObject, nil)
               }
           } catch {
               DispatchQueue.main.async {
                   completion(nil, error)
               }
           }
        }

        task.resume()
    }
}
