//
//  DataManager.swift
//  IOS Take Home Prompt
//
//  Created by Danilo Oliveira on 16/04/24.
//

import Foundation

class DataManager {
    static func loadVideos() -> [VideoModel] {
        guard let url = Bundle.main.url(forResource: "videos", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load videos.json from bundle.")
        }

        let decoder = JSONDecoder()
        do {
            let videoData = try decoder.decode([String: [VideoModel]].self, from: data)
            return videoData["videos"] ?? []
        } catch {
            fatalError("Error parsing JSON data: \(error)")
        }
    }
}

