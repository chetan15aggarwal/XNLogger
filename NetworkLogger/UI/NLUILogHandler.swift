//
//  NLUILogHandler.swift
//  XNLogger
//
//  Created by Sunil Sharma on 23/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public class NLUILogHandler: XNBaseLogHandler, XNLogHandler {
    
    private var logComposer: XNLogComposer!
    weak var delegate: NLUILogDataDelegate?
    
    public class func create() -> NLUILogHandler {
        let instance: NLUILogHandler = NLUILogHandler()
        instance.logComposer = XNLogComposer(logFormatter: instance.logFormatter)
        return instance
    }
    
    public func networkLogger(logRequest logData: XNLogData) {
        if shouldLogRequest(logData: logData) || logFormatter.showReqstWithResp {
            delegate?.receivedLogData(logData, isResponse: false)
        }
    }
    
    public func networkLogger(logResponse logData: XNLogData) {
        if shouldLogResponse(logData: logData) {
            delegate?.receivedLogData(logData, isResponse: true)
        }
    }
    
}
