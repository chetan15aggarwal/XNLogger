//
//  ConsoleLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class NLConsoleLogHandler: NSObject, NLLogHandler {
    
    private var filters: [NLFilter]?
    private let logComposer = LogComposer()
    
    init(filters: [NLFilter]?) {
        self.filters = filters
    }
    
    public func logNetworkRequest(_ urlRequest: URLRequest) {
        if let filters = self.filters, filters.count > 0 {
            for filter in filters where filter.shouldLog(urlRequest: urlRequest) {
                print(logComposer.getRequestLog(from: urlRequest))
                break
            }
        }
        else {
            print(logComposer.getRequestLog(from: urlRequest))
        }
    }
    
    public func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        if let filters = self.filters, filters.count > 0 {
            for filter in filters where filter.shouldLog(urlRequest: urlRequest) {
                print(logComposer.getResponseLog(urlRequest: urlRequest, response: responseData))
                break
            }
        } else {
            print(logComposer.getResponseLog(urlRequest: urlRequest, response: responseData))
        }
        
    }
    
}
