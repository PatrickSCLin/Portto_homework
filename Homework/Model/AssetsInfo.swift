//
//  AssetsInfo.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import Foundation

struct AssetsInfo: Decodable {
    let previous: String?
    let next: String?
    let assets: [AssetInfo]
}
