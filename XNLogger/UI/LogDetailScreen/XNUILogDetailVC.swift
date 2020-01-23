//
//  XNUILogDetailVC.swift
//  XNLogger
//
//  Created by Sunil Sharma on 27/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class XNUILogDetailVC: XNUIBaseViewController {
    
    class func instance() -> XNUILogDetailVC? {
        
        let controller = XNUILogDetailVC(nibName: String(describing: self), bundle: Bundle.current())
        return controller
    }

    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var responseBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var logData: XNLogData?
    private var requestView: XNUILogDetailView?
    private var responseView: XNUILogDetailView?
    private var isResponseSelected: Bool = false
    private var logDataConverter: NLUILogDataConverter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        self.automaticallyAdjustsScrollViewInsets = false
        self.tabBarController?.tabBar.isHidden = true
        
        configureViews()
        if let logData = self.logData {
            self.logDataConverter = NLUILogDataConverter(logData: logData, formatter: XNUIManager.shared.uiLogHandler.logFormatter)
        }
        selectDefaultTab()
    }
    
    private func configureViews() {
        self.navigationItem.title = "Log details"
        self.view.layoutIfNeeded()
        if (requestView == nil) {
            requestView = XNUILogDetailView(frame: contentView.bounds)
            requestView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            requestView?.translatesAutoresizingMaskIntoConstraints = true
            if let subView = requestView {
                self.contentView.addSubview(subView)
            }
        }
        
        if (responseView == nil) {
            responseView = XNUILogDetailView(frame: contentView.bounds)
            responseView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            responseView?.translatesAutoresizingMaskIntoConstraints = true
            if let subView = responseView {
                self.contentView.addSubview(subView)
            }
        }
    }
    
    private func selectDefaultTab() {
        self.responseView?.isHidden = true
        self.requestView?.isHidden = false
        self.requestView?.upadteView(with: logDataConverter?.getRequestLogDetails() ?? [])
        self.responseView?.upadteView(with: logDataConverter?.getResponseLogDetails() ?? [])
        clickedOnRequest(UIButton(type: .custom))
    }
    
    @IBAction func clickedOnRequest(_ sender: Any) {
        if isResponseSelected {
            self.responseView?.isHidden = true
        }
        self.requestView?.isHidden = false
        self.isResponseSelected = false
        
        self.requestBtn.backgroundColor = XNUIAppColor.lightPrimary
        self.requestBtn.setTitleColor(.white, for: .normal)
        self.responseBtn.backgroundColor = .white
        self.responseBtn.setTitleColor(XNUIAppColor.title, for: .normal)
    }
    
    @IBAction func clickedOnResponse(_ sender: Any) {
        if isResponseSelected == false {
            self.requestView?.isHidden = true
        }
        self.responseView?.isHidden = false
        self.isResponseSelected = true
        
        self.responseBtn.backgroundColor = XNUIAppColor.lightPrimary
        self.responseBtn.setTitleColor(.white, for: .normal)
        self.requestBtn.backgroundColor = .white
        self.requestBtn.setTitleColor(XNUIAppColor.title , for: .normal)
    }

}

class NLUILogDataConverter {
    
    private var logData: XNLogData!
    private var formatter: XNLogFormatter!
    let dateFormatter = DateFormatter()
    
    init(logData: XNLogData, formatter: XNLogFormatter) {
        self.logData = logData
        self.formatter = formatter
        self.dateFormatter.dateFormat = "yyyy-MM-dd H:m:ss.SSSS"
    }
    
    func getRequestLogDetails() -> [XNUILogDetail] {
        var requestLogs: [XNUILogDetail] = []
        if formatter.showRequest || formatter.showReqstWithResp {
            let urlInfo: XNUILogDetail = XNUILogDetail(title: "URL")
            urlInfo.messages.append(logData.urlRequest.url?.absoluteString ?? "-")
            requestLogs.append(urlInfo)
            if let port = logData.urlRequest.url?.port {
                requestLogs.append(XNUILogDetail(title: "Port", message: "\(port)"))
            }
            requestLogs.append(XNUILogDetail(title: "Method", message: logData.urlRequest.httpMethod ?? "-"))
            let headerInfo: XNUILogDetail = XNUILogDetail(title: "Header fields")
            if let headerFields = logData.urlRequest.allHTTPHeaderFields, headerFields.isEmpty == false {
                for (key, value) in headerFields {
                    headerInfo.messages.append("\(key) = \(value)")
                }
            } else {
                headerInfo.messages.append("Header field is empty")
            }
            requestLogs.append(headerInfo)
            
            let httpBodyInfo: XNUILogDetail = XNUILogDetail(title: "Http body")
            
            if let httpBody = logData.urlRequest.httpBodyString(prettyPrint: formatter.prettyPrintJSON), httpBody.isEmpty == false {
                // Log HTTP body either `logUnreadableReqstBody` is true or when content is readable.
                if formatter.logUnreadableReqstBody || XNAppUtils.shared.isContentTypeReadable(logData.reqstContentType) {
                    httpBodyInfo.messages.append("\(httpBody)")
                } else {
                    httpBodyInfo.messages.append("\(logData.reqstContentType.getName())")
                    httpBodyInfo.shouldShowDataInFullScreen = true
                }
            } else {
                httpBodyInfo.messages.append("Http body is empty")
            }
            
            requestLogs.append(httpBodyInfo)
            
            if formatter.showCurlWithReqst {
                requestLogs.append(XNUILogDetail(title: "CURL", message: logData.urlRequest.cURL))
            }
            
            let reqstMetaInfo: [XNRequestMetaInfo] = formatter.showReqstMetaInfo
            
            for metaInfo in reqstMetaInfo {
                
                switch metaInfo {
                case .timeoutInterval:
                    requestLogs.append(XNUILogDetail(title: "Timeout interval", message: "\(logData.urlRequest.timeoutInterval)"))
                case .cellularAccess:
                    requestLogs.append(XNUILogDetail(title: "Mobile data access allowed", message: "\(logData.urlRequest.allowsCellularAccess)"))
                case .cachePolicy:
                    requestLogs.append(XNUILogDetail(title: "Cache policy", message: "\(logData.urlRequest.getCachePolicyName())"))
                case .networkType:
                    requestLogs.append(XNUILogDetail(title: "Network service type", message: "\(logData.urlRequest.getNetworkTypeName())"))
                case .httpPipeliningStatus:
                    requestLogs.append(XNUILogDetail(title: "HTTP Pipelining will be used", message: "\(logData.urlRequest.httpShouldUsePipelining)"))
                case .cookieStatus:
                    requestLogs.append(XNUILogDetail(title: "Cookies will be handled", message: "\(logData.urlRequest.httpShouldHandleCookies)"))
                case .requestStartTime:
                    if let startDate: Date = logData.startTime {
                        requestLogs.append(XNUILogDetail(title: "Start time", message: "\(dateFormatter.string(from: startDate))"))
                    }
                }
            }
        }
        
        return requestLogs
    }
    
    func getResponseLogDetails() -> [XNUILogDetail] {
        var responseLogs: [XNUILogDetail] = []
        if formatter.showResponse {
            
            let responseInfo: XNUILogDetail = XNUILogDetail(title: "Response Content")
            if let data = logData.receivedData, data.isEmpty == false {
                let jsonUtil = XNJSONUtils()
                if formatter.logUnreadableRespBody || XNAppUtils.shared.isContentTypeReadable(logData.respContentType) {
                    let str = jsonUtil.getJSONStringORStringFrom(jsonData: data, prettyPrint: formatter.prettyPrintJSON)
                    responseInfo.messages.append(str)
                } else {
                    responseInfo.messages.append(logData.respContentType.getName())
                }
            }
            else {
                responseInfo.messages.append("Respose data is empty")
            }
            responseLogs.append(responseInfo)
            
            let respMetaInfo: XNUILogDetail = XNUILogDetail(title: "Response Meta Info")
            if formatter.showRespMetaInfo.isEmpty == false {
                let respHeaderInfo: XNUILogDetail = XNUILogDetail(title: "Response headers fields:")
                let response = logData.response
                for property in formatter.showRespMetaInfo {
                    
                    switch property {
                    case .statusCode:
                        if let httpResponse = response as? HTTPURLResponse {
                            respMetaInfo.messages.append("Status Code: \(httpResponse.statusCode)")
                        }
                    case .statusDescription:
                        if let httpResponse = response as? HTTPURLResponse {
                            respMetaInfo.messages.append("Status Code description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                        }
                    case .mimeType:
                        respMetaInfo.messages.append("Mime type: \(response?.mimeType ?? "-")")
                    case .textEncoding:
                        respMetaInfo.messages.append("Text encoding name: \(response?.textEncodingName ?? "-")")
                    case .contentLength:
                        if let expectedContentLength = response?.expectedContentLength {
                            respMetaInfo.messages.append("Expected content length: \(expectedContentLength)")
                        } else {
                            respMetaInfo.messages.append("Expected content length: -")
                        }
                    case .suggestedFileName:
                        respMetaInfo.messages.append("Suggested file name: \(response?.suggestedFilename ?? "-")")
                    case .headers:
                        if let httpResponse = response as? HTTPURLResponse,
                            httpResponse.allHeaderFields.isEmpty == false {
                            
                            for (key, value) in httpResponse.allHeaderFields {
                                respHeaderInfo.messages.append("\(key) = \(value)")
                            }
                        }
                    case .requestStartTime:
                        if let startDate: Date = logData.startTime {
                            respMetaInfo.messages.append("Start time: \(dateFormatter.string(from: startDate))")
                        }
                    case .duration:
                        if let durationStr: String = logData.getDurationString() {
                            respMetaInfo.messages.append("Duration: " + durationStr)
                        } else {
                            respMetaInfo.messages.append("Duration: -")
                        }
                    }
                }
                responseLogs.append(respMetaInfo)
                if respHeaderInfo.messages.isEmpty == false {
                    responseLogs.append(respHeaderInfo)
                }
            }
            else {
                respMetaInfo.messages.append("Response meta info is empty")
            }
            
            if let error = logData.error {
                responseLogs.append(XNUILogDetail(title: "Response Error", message: error.localizedDescription))
            }
            
        }
        return responseLogs
    }
}
