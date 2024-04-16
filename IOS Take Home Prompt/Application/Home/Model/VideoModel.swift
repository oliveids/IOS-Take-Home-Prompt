//
//  VideoModel.swift
//  IOS Take Home Prompt
//
//  Created by Danilo Oliveira on 16/04/24.
//

import Foundation

struct VideoModel: Codable {
    let id: Int
    let songUrl: String
    let body: String
    let profilePictureUrl: String
    let username: String
    let compressedForIosUrl: String

    enum CodingKeys: String, CodingKey {
        case id, body, username
        case songUrl = "song_url"
        case profilePictureUrl = "profile_picture_url"
        case compressedForIosUrl = "compressed_for_ios_url"
    }
}
