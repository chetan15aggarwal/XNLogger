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
     Setup and start logging network calls.
     */
    func startInterceptingNetwork() {
        /// Before swizzle checking if it's already not swizzled.
        /// If it already swizzled skip else swizzle for logging.
        /// This check make safe to call multiple times.
        if isProtocolSwizzled() == false {
            swizzleProtocolClasses()
        }
    }
    
    /**
     Stop intercepting network calls and revert back changes made to
     intercept network calls.
     */
    func stopInterceptingNetwork() {
        /// Check if already unswizzled for logging, if so then skip
        /// else unswizzle for logging i.e. it will stop logging.
        /// Check make it safe to call multiple times.
        if isProtocolSwizzled() {
            swizzleProtocolClasses()
        }
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
            let customProtocolClass: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.nlProcotolClasses)) {
            method_exchangeImplementations(originalProtocolGetter, customProtocolClass)
        } else {
            print("NL: Failed to swizzle protocol classes")
        }
    }
    
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

