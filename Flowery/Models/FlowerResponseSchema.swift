//
//  FlowerData.swift
//  Flowery
//
//  Created by Artem Tkachuk on 8/7/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import Foundation

struct FlowerResponseSchema: Codable {
    let query: Query
}

struct Query: Codable {
    let pageids: [String]
    let pages: [String: PageInfo]
}

struct PageInfo: Codable {
    let extract: String
    let thumbnail: Thumbnail
}

struct Thumbnail: Codable {
    let source: String
}
