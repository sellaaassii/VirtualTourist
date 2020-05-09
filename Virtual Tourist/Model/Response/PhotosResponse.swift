//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Selasi Kudolo on 2020-05-08.
//  Copyright © 2020 Selasi. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photo: [PhotoResponse]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}
