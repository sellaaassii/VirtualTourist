//
//  FlickrAPIResponse.swift
//  Virtual Tourist
//
//  Created by Selasi Kudolo on 2020-05-08.
//  Copyright © 2020 Selasi. All rights reserved.
//

import Foundation

struct FlickrAPIResponse: Codable {
    let photos: PhotosResponse
    let stat: String
}
