//
//  Photos.swift
//  SwiftUI_PhotosAPI_MVVM_Protocols_Network Interchange
//
//  Created by Eren Elçi on 9.11.2024.
//

import Foundation

struct Photo: Codable {
    let albumID: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailURL: String

    enum CodingKeys: String, CodingKey {
        case albumID = "albumId"
        case id, title, url
        case thumbnailURL = "thumbnailUrl"
    }
}
