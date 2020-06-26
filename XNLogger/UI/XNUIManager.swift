//
//  XNUIManager.swift
//  Predicator
//
//  Created by Sunil Sharma on 21/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation
import UIKit

@objc
public enum XNGestureType: Int {
    case shake
    case custom
}

protocol XNUILogDataDelegate: class {
    func receivedLogData(_ logData: XNLogData, isResponse: Bool)
}

/**
 Handle XNLogger UI data
 */
@objc
public final class XNUIManager: NSObject {
    
    @objc public static let shared: XNUIManager = XNUIManager()
    public var startGesture: XNGestureType? = .shake
    var uiLogHandler: XNUILogHandler = XNUILogHandler.create()
    private var logsDataDict: [String: XNUILogInfo] = [:]
    private var logsIdArray: [String] = []
    private var logsActionThread = DispatchQueue.init(label: "XNUILoggerLogListActionThread", qos: .userInteractive, attributes: .concurrent)
    private let fileService: XNUIFileService = XNUIFileService()
    private var logWindow: XNUIWindow?
    
    private override init() {
        super.init()
        XNLogger.shared.addLogHandlers([uiLogHandler])
        self.uiLogHandler.delegate = self
        // Previous logs
        XNUIFileService().removeLogDirectory()
        
        XNLogger.shared.addLogHandlers([XNConsoleLogHandler.create()])
    }
    
    // Return current root view controller
    private var presentingViewController: UIViewController? {
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        while let controller = rootViewController?.presentedViewController {
            rootViewController = controller
        }
        return rootViewController
    }
    
    // Preset network logger UI to user. This is start point of UI
    @objc public func presentNetworkLogUI() {
        
        if let presentingViewController = self.presentingViewController, !(presentingViewController is XNUIBaseTabBarController) {
            
            if let tabbarVC = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "nlMainTabBarController") as? UITabBarController {
                tabbarVC.modalPresentationStyle = .fullScreen
                logWindow = XNUIWindow(frame: UIScreen.main.bounds)
                logWindow?.present(rootVC: tabbarVC)
//                presentingViewController.present(tabbarVC, animated: true, completion: nil)
            }
        }
    }
    
    // Dismiss network logger UI
    @objc public func dismissNetworkUI() {
        logWindow?.dismiss()
        logWindow = nil
//        if let presentingViewController = self.presentingViewController as? XNUIBaseTabBarController {
//            presentingViewController.dismiss(animated: true, completion: nil)
//        }
    }
    
    @objc public func clearLogs() {
        logsActionThread.async(flags: .barrier) {
            self.logsDataDict = [:]
            self.logsIdArray.removeAll()
            self.fileService.removeLogDirectory()
            if let tempDirURL = self.fileService.getTempDirectory() {
                self.fileService.removeFile(url: tempDirURL)
            }
        }
    }
    
    func removeLogAt(index: Int) {
        logsActionThread.async(flags: .barrier) {
            let logId = self.logsIdArray[index]
            self.logsIdArray.remove(at: index)
            self.logsDataDict.removeValue(forKey: logId)
            self.fileService.removeLog(logId)
        }
    }
    
    func getLogsIdArray() -> [String] {
        var logArray: [String]?
        logsActionThread.sync {
           logArray = self.logsIdArray
        }
        return logArray ?? []
    }
    
    func getLogsDataDict() -> [String: XNUILogInfo] {
        var logsDict: [String: XNUILogInfo]?
        logsActionThread.sync {
            logsDict = self.logsDataDict
        }
        return logsDict ?? [:]
    }
    
    func getXNUILogInfoModel(from logData: XNLogData) -> XNUILogInfo {
        let logInfo = XNUILogInfo(logId: logData.identifier)
        if let scheme = logData.urlRequest.url?.scheme,
            let host = logData.urlRequest.url?.host, let path = logData.urlRequest.url?.path {
            logInfo.title = "\(scheme)://\(host)\(path)"
        } else {
            logInfo.title = logData.urlRequest.url?.absoluteString ?? "No URL found"
        }
        logInfo.httpMethod = logData.urlRequest.httpMethod
        logInfo.startTime = logData.startTime
        logInfo.durationStr = logData.getDurationString()
        logInfo.state = logData.state
        if let httpResponse = logData.response as? HTTPURLResponse {
            logInfo.statusCode = httpResponse.statusCode
        }
        return logInfo
    }
    
}

extension XNUIManager: XNUILogDataDelegate {
    
    func receivedLogData(_ logData: XNLogData, isResponse: Bool) {
        
        logsActionThread.async(flags: .barrier) {
            if isResponse == false {
                // Request
                self.logsIdArray.append(logData.identifier)
            }
            self.logsDataDict[logData.identifier] = self.getXNUILogInfoModel(from: logData)
            
            if isResponse == false {
                // Request
                self.fileService.saveLogsDataOnDisk(logData, completion: nil)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .logDataUpdate, object: nil, userInfo: [XNUIConstants.logIdKey: logData.identifier])
                }
            } else {
                // Response
                self.fileService.saveLogsDataOnDisk(logData) {
                    // Post response notification on completion of write operation
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .logDataUpdate, object: nil, userInfo: [XNUIConstants.logIdKey: logData.identifier])
                    }
                }
            }
        }
    }
}
