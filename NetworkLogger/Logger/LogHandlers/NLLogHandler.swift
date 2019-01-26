//
//  NLLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public protocol NLLogHandler {
    
    func logNetworkRequest(_ urlRequest: URLRequest)
    func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData)
    
}

public enum NLLogHandlerType {
    
    case console([NLFilter]?)
    case slack(NLSlackUser)
    case remote
    
}
