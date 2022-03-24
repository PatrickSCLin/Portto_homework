//
//  AssetInfo.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import Foundation

struct AssetInfo: Decodable {
    let image_url: String?
    let name: String?
    let description: String?
    let permalink: String?
    let collection: Collection?
}
