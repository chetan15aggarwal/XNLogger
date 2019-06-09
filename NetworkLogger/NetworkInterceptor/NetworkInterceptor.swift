//
//  NetworkInterceptor.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 03/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

internal class NetworkInterceptor: NSObject {
    
    /**
     Setup and start logging network calls
     */
    func startInterceptingNetwork() {
        if isProtocolSwizzled() == false {
            swizzleProtocolClasses()
        }
    }
    
    /**
     Stop intercepting network calls and revert back changes made to
     intercept network calls.
     */
    func stopInterceptingNetwork() {
        unswizzleProtocolClasses()
    }
    
    func isProtocolSwizzled() -> Bool {
        let protocolClasses: [AnyClass] = URLSessionConfiguration.default.protocolClasses ?? []
        for protocolCls in protocolClasses {
            if protocolCls == NLURLProtocol.self {
                return true
            }
        }
        return false
    }
    
    func swizzleProtocolClasses() {
        let instance = URLSessionConfiguration.default
        if let uRLSessionConfigurationClass: AnyClass = object_getClass(instance),
            let originalProtocolGetter: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses)),
            let customProtocolClass: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.nlProcotolClasses)){
            method_exchangeImplementations(originalProtocolGetter, customProtocolClass)
        } else {
            debugPrint("Failed to swizzle protocol classes")
        }
    }
    
    func unswizzleProtocolClasses() {
        if isProtocolSwizzled() {
            swizzleProtocolClasses()
        }
    }
    
    /**
     Now not used. Should be removed
     Swizzle original Data task method with Interceptable Data task method.
 
    func swizzleDataTask() {
        
        let sessionInstance = URLSession(configuration: .default)
        guard let urlSessionClass: AnyClass = object_getClass(sessionInstance) else {
            debugPrint("Failed to get URLSession Class")
            return
        }
        
        let dataTaskSel = #selector((URLSession.dataTask(with:completionHandler:)) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        
        let interceptableDataTaskSel = #selector((URLSession.interceptableDataTask(with:completionHandler:)) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        
        if let originalMethod = class_getInstanceMethod(urlSessionClass, dataTaskSel),
            let interceptableMethod = class_getInstanceMethod(URLSession.self, interceptableDataTaskSel) {
            method_exchangeImplementations(originalMethod, interceptableMethod)
        }
        else {
            debugPrint("Failed to get data task method instance")
        }
    }
     */
}

extension URLSessionConfiguration {
    
    /**
    Never call this method directly.
    Always use `protocolClasses` to get protocol classes.
    */
    @objc func nlProcotolClasses() -> [AnyClass]? {
        guard let nlProcotolClasses = self.nlProcotolClasses() else {
            return []
        }
        var originalProtocolClasses = nlProcotolClasses.filter {
            return $0 != NLURLProtocol.self
        }
        // Make sure NLURLProtocol class is at top in protocol classes list.
        originalProtocolClasses.insert(NLURLProtocol.self, at: 0)
        return originalProtocolClasses
    }
}

/**
 Implement interceptable data task method.
 
internal extension URLSession {
    
    @objc func interceptableDataTask(with request: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) -> URLSessionDataTask {
        
        NetworkLogger.shared.logRequest(request)
        
        let sessionDataTask = self.interceptableDataTask(with: request) { (data, response, error) in
            
            let responseData = NLResponseData(response: response, responseData: data, error: error)
            NetworkLogger.shared.logResponse(for: request, responseData: responseData)
            
            completionHandler?(data, response, error)
        }
        return sessionDataTask
    }
    
}
 */

