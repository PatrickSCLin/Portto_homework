//
//  OpenSeaAPI.swift
//  Homework
//
//  Created by Patrick Lin on 2022/3/21.
//

import Moya

enum OpenSeaAPI {
    case assets(owner: String, cursor: String = "", limit: Int = 20)
}

extension OpenSeaAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.opensea.io/api/v1")!
    }
    
    var path: String {
        switch self {
        case .assets:
            return "/assets"
        }
    }
    
    var method: Method {
        switch self {
        case .assets:
            return .get
        }
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case let .assets(owner, cursor, limit):
            parameters["owner"] = owner
            parameters["cursor"] = cursor
            parameters["limit"] = limit
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    }
    
    var headers: [String : String]? {
        return ["X-API-KEY": "5b294e9193d240e39eefc5e6e551ce83"]
    }
}
