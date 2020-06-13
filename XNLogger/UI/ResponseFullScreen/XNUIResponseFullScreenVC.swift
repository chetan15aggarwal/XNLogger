//
//  XNUIResponseFullScreenVC.swift
//  XNLogger
//
//  Created by Sunil Sharma on 04/04/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import Foundation
import WebKit

class XNUIResponseFullScreenVC: XNUIBaseViewController {
    
    @IBOutlet weak var mediaWebView: WKWebView!
    @IBOutlet weak var msgTextView: XNUILogTextView!
    
    var headerTitle: String!
    var logData: XNUIMessageData!
    let fileService: XNUIFileService = XNUIFileService()
    var isFirstLoad: Bool = true
    var mediaFileUrl: URL?
    let helper: XNUIHelper = XNUIHelper()
    
    class func controller(title: String, logData: XNUIMessageData) -> XNUIResponseFullScreenVC? {
        let controller = XNUIResponseFullScreenVC(nibName: String(describing: self), bundle: Bundle.current())
        controller.logData = logData
        controller.headerTitle = title
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstLoad {
            isFirstLoad = false
            loadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.navigationController?.viewControllers.firstIndex(of: self) == nil {
            if let fileURL = self.mediaFileUrl {
                fileService.removeFile(url: fileURL)
            }
        }
    }
    
    func configureViews() {
        self.navigationItem.title = headerTitle
        self.msgTextView.text = nil
        self.mediaWebView.navigationDelegate = self
        // Show share icon
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.clickedOnMoreOptions))
    }
    
    func loadData() {
        self.view.layoutIfNeeded()
        helper.showActivityIndicator(on: self.view)
        // Check for readable text
        if logData.message.isEmpty == false {
            self.mediaWebView.isHidden = true
            self.msgTextView.isHidden = false
            self.msgTextView.text = logData.message
            self.helper.hideActivityIndicator(from: self.view)
        } else if let contentData = self.logData.data {
            let ext = self.logData.fileMeta?.ext ?? "txt"
            self.mediaWebView.isHidden = false
            self.msgTextView.isHidden = true
            
            fileService.writeMedia(data: contentData, ext: ext) {[weak self] (fileUrl) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.mediaFileUrl = fileUrl
                    if let fileURL = fileUrl {
                        self.mediaWebView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
                    } else {
                        self.helper.hideActivityIndicator(from: self.view)
                        self.helper.showError(on: self, message: "Something went wrong while processing file.")
                    }
                }
            }
        }
        else {
            self.helper.hideActivityIndicator(from: self.view)
            self.helper.showError(on: self, message: "Something went wrong while processing file.")
        }
    }
    
    @objc func clickedOnMoreOptions() {
        showShareController()
    }
    
    func showShareController() {
        
        var shareDetails: XNUIShareData? = nil
        
        if self.logData.message.isEmpty == false {
            let logDetail = XNUILogDetail(title: headerTitle, messageData: logData)
            shareDetails = XNUIShareData(logDetails: [logDetail])
        } else if let fileURL = self.mediaFileUrl {
            shareDetails = XNUIShareData(fileURL: fileURL)
        }
        
        guard let shareItem = shareDetails else {
            self.helper.showError(on: self, message: "Unable to perform action.")
            return
        }
        let ac = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        ac.completionWithItemsHandler = {[weak self] (activityType, completed, returnedItems, activityError) in
            guard let self = self else {
                shareItem.clean()
                return
            }
            
            if self.logData.message.isEmpty == false {
                shareItem.clean()
            }
            if let error = activityError {
                self.helper.showError(on: self, message: error.localizedDescription)
            }
        }
        present(ac, animated: true)
    }
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
}

extension XNUIResponseFullScreenVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        helper.showActivityIndicator(on: self.view)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        helper.hideActivityIndicator(from: self.view)
    }
}
