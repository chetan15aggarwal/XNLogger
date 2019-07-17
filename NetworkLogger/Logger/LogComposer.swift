//
//  LogComposer.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

internal class LogComposer {
    
    let formatter: NLLogFormatter
    let dateFormatter = DateFormatter()
    
    init(logFormatter: NLLogFormatter) {
        self.formatter = logFormatter
        self.dateFormatter.dateFormat = "yyyy-MM-dd H:m:ss.SSSS"
    }
    
    func getRequestLog(from logData: NLLogData) -> String {
        return getRequestLog(from: logData, isResponseLog: false)
    }
    
    private func getRequestLog(from logData: NLLogData, isResponseLog: Bool) -> String {
        let urlRequest: URLRequest = logData.urlRequest
        var urlRequestStr = ""
        urlRequestStr += "\n\(getBoundry(for: "Request"))\n"
        urlRequestStr += "\nId: \(getIdentifierString(logData.identifier))"
        urlRequestStr += "\nURL: \(urlRequest.url?.absoluteString ?? "-")"
        if let port = urlRequest.url?.port {
            urlRequestStr += "\nPort: \(port)"
        }
        urlRequestStr += "\nMethod: \(urlRequest.httpMethod ?? "-")"
        if let headerFields = urlRequest.allHTTPHeaderFields, headerFields.isEmpty == false {
            urlRequestStr += "\n\nHeaders fields:"
            for (key, value) in headerFields {
                urlRequestStr.append("\n\(key) = \(value)")
            }
        }
        
        if let httpBody = urlRequest.httpBodyString(prettyPrint: true) {
            urlRequestStr.append("\n\nHttp Body:")
            urlRequestStr.append("\n\(httpBody)\n")
        }
        
        let showCurl: Bool = isResponseLog ? formatter.showCurlWithResp : formatter.showCurlWithReqst
        
        if showCurl {
            urlRequestStr += "\nCURL: \(urlRequest.cURL)"
        }
        
        let reqstMetaInfo: [NLRequestMetaInfo] = isResponseLog ? formatter.showReqstMetaInfoWithResp : formatter.showReqstMetaInfo
        
        for metaInfo in reqstMetaInfo {
            
            switch metaInfo {
            case .timeoutInterval:
                urlRequestStr += "\nTimeout interval: \(urlRequest.timeoutInterval)"
            case .cellularAccess:
                urlRequestStr += "\nMobile data access allowed: \(urlRequest.allowsCellularAccess)"
            case .cachePolicy:
                urlRequestStr += "\nCache policy: \(urlRequest.getCachePolicyName())"
            case .networkType:
                urlRequestStr += "\nNetwork service type: \(urlRequest.getNetworkTypeName())"
            case .httpPipeliningStatus:
                urlRequestStr += "\nHTTP Pipelining will be used: \(urlRequest.httpShouldUsePipelining)"
            case .cookieStatus:
                urlRequestStr += "\nCookies will be handled: \(urlRequest.httpShouldHandleCookies)"
            case .requestStartTime:
                if let startDate: Date = logData.startTime {
                    urlRequestStr += "\nStart time: \(dateFormatter.string(from: startDate))"
                }
            case .threadName:
                urlRequestStr += "\nThread: Coming soon..."
            }
        }
        
        urlRequestStr += "\n\n\(getBoundry(for: "Request End"))\n"
        
        return urlRequestStr
    }
    
    func getResponseLog(from logData: NLLogData) ->  String {
        
        var responseStr: String = ""
        
        if formatter.showReqstWithResp {
            responseStr.append(getRequestLog(from: logData, isResponseLog: true))
        }
        
        responseStr += "\n\(getBoundry(for: "Response"))\n"
        responseStr += "\nId: \(getIdentifierString(logData.identifier))"
        
        // Response Meta Info
        if let response = logData.response, formatter.showRespMetaInfo.isEmpty == false {
            responseStr += "\nResponse Meta Info:"
            
            for property in formatter.showRespMetaInfo {
                
                switch property {
                case .statusCode:
                    if let httpResponse = response as? HTTPURLResponse {
                        responseStr += "\nStatus Code: \(httpResponse.statusCode)"
                    }
                case .statusDescription:
                    if let httpResponse = response as? HTTPURLResponse {
                        responseStr += "\nStatus Code description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    }
                case .mimeType:
                    responseStr += "\nMime type: \(response.mimeType ?? "-")"
                case .textEncoding:
                    responseStr += "\nText encoding name: \(response.textEncodingName ?? "-")"
                case .contentLength:
                    responseStr += "\nExpected content length: \(response.expectedContentLength)"
                case .suggestedFileName:
                    responseStr += "\nSuggested file name: \(response.suggestedFilename ?? "-")"
                case .headers:
                    if let httpResponse = response as? HTTPURLResponse,
                        httpResponse.allHeaderFields.isEmpty == false {
                        
                        responseStr += "\n\nResponse headers fields:"
                        for (key, value) in httpResponse.allHeaderFields {
                            responseStr.append("\n\(key) = \(value)")
                        }
                    }
                case .requestStartTime:
                    if let startDate: Date = logData.startTime {
                        responseStr.append("\nStart time: \(dateFormatter.string(from: startDate))")
                    }
                case .duration:
                    if let durationStr: String = logData.getDurationString() {
                        responseStr.append("\nDuration: " + durationStr)
                    } else {
                        responseStr.append("\nDuration: -")
                    }
                case .threadName:
                    responseStr.append("\nThread: Coming soon...")
                }
            }
        }
        
        if let error = logData.error {
            responseStr += "\n\nResponse Error:\n"
            responseStr += error.localizedDescription
        }
        
        if let data = logData.receivedData, data.isEmpty == false {
            responseStr += "\n\nResponse Content: \n"
            if formatter.prettyPrintJSON, let str = JSONUtils.shared.getJSONPrettyPrintORStringFrom(jsonData: data) {
                responseStr.append(str)
            } else {
                responseStr.append(JSONUtils.shared.getStringFrom(data: data))
            }
        }
        
        responseStr += "\n\n\(getBoundry(for: "Response End"))"
        return responseStr
    }
    
    private func getIdentifierString(_ identifier: String) -> String {
        return "\(identifier) (Generated by NetworkLogger)"
    }
    
    private func getBoundry(for message: String) -> String {
        return "====== \(message) ======"
    }
}
