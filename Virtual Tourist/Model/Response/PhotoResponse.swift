//
//  PhotoResponse.swift
//  Virtual Tourist
//
//  Created by Selasi Kudolo on 2020-05-08.
//  Copyright © 2020 Selasi. All rights reserved.
//

import Foundation

struct PhotoResponse: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int

    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}
