//
//  NetworkLogger.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 16/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public class NetworkLogger: NSObject {
    
    // Public variables
    @objc public static let shared = NetworkLogger()
    
    // Private variables
    private let networkInterceptor = NetworkInterceptor()
    private var handlers:[NLLogHandler] = []
    
    override private init() {}
    
    public func startLogging() {
        debugPrint("Started logging network traffic")
        networkInterceptor.startInterceptingNetwork()
    }
    
    public func stopLogging() {
        debugPrint("Stopped logging network traffic")
        networkInterceptor.stopInterceptingNetwork()
    }
    
    public func addLogHandler(_ handler: NLLogHandler) {
        self.handlers.append(handler)
    }
    
    public func addLogHandlers(_ handlers: [NLLogHandler]) {
        self.handlers.append(contentsOf: handlers)
    }
    
    func logResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        
        for handler in self.handlers {
            handler.logNetworkResponse(for: urlRequest, responseData: responseData)
        }
        
    }
    
    func logRequest(_ urlRequest: URLRequest) {
        
        for handler in self.handlers {
            handler.logNetworkRequest(urlRequest)
        }
    }
    
}
