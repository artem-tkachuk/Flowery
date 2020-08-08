//
//  FlowerModel.swift
//  Flowery
//
//  Created by Artem Tkachuk on 8/7/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import Foundation

struct FlowerModel {
    let extract: String
    let thumbnail: String
    
    init(_ extract: String, _ thumbnail: String) {
        self.extract = extract
        self.thumbnail = thumbnail
    }
}
