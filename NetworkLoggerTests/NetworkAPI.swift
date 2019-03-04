//
//  Constants.swift
//  NetworkLoggerTests
//
//  Created by Sunil Sharma on 12/02/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

//This defines the type of HTTP method used to perform the request
public enum HTTPMethod: String {
    case post = "POST"
    case put = "PUT"
    case get = "GET"
    case delete = "DELETE"
    case patch = "PATCH"
}

//Environment is a struct which encapsulate all the information
public struct Environment {
    
    //Name of the environment
    public var name: String
    
    //Base URL of the environment
    public var host: String
    
    //This is the list of common headers which will be part of each Request
    public var headers: [String: Any] = [:]
    
    //Cache policy
    public var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
    //Initialize a new Environment
    public init(_ name: String, host: String) {
        self.name = name
        self.host = host
    }
}

public protocol Request {
    var path: String { get }
    var url: URL? { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: Any]? { get }
}

private(set) var environment = Environment("Local", host: "http://localhost:8080")


enum API {
    case localInfo
    case userInfo
}

extension API: Request {
    
    var path: String {
        
        switch self {
        case .localInfo:
            return "/info"
        case .userInfo:
            return "/info"
        }
    }
    
    var url: URL? {
        switch self {
        case .localInfo:
            return URL(string: "\(environment.host)\(API.localInfo.path)")
        case .userInfo:
            return URL(string: "\(environment.host)\(API.localInfo.path)")
        }
    }
    
    
    var method: HTTPMethod {
        
        switch self {
        case .localInfo, .userInfo:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        
        switch self {
        case .localInfo:
            return [:]
        case .userInfo:
            return [:]
        }
    }
    
    var headers: [String : Any]? {
        
        switch self {
        case .localInfo:
            return [:]
        case .userInfo:
            return [:]
        }
    }
    
    
}


class DummyResponse {
    
    class func get(forAPI api: API) -> AnyObject {
        switch api {
        case .localInfo:
            return ["hello": "welcome"] as AnyObject
        case .userInfo:
            return [:] as AnyObject
        }
    }
    
}
