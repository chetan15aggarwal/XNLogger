//
//  NLUILogDetail.swift
//  XNLogger
//
//  Created by Sunil Sharma on 29/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class XNUIMessageData {
    
    var message: String
    var msgCount: Int = 0
    var msgSize: Int = 0
    var showOnlyInFullScreen: Bool = false
    
    init(msg: String) {
        self.message = msg
    }
}

class XNUILogDetail {
    
    var title: String
    var messages: [XNUIMessageData] = []
    var isExpended: Bool = false
    
    init(title: String) {
        self.title = title
    }
    
    convenience init(title: String, message: String) {
        self.init(title: title)
        addMessage(message)
    }
    
    func addMessage(_ msg: String, showOnlyInFullScreen: Bool = false) {
        let msgInfo = XNUIMessageData(msg: msg)
        msgInfo.msgCount = msg.count
        msgInfo.msgSize = msg.lengthOfBytes(using: .utf8)
        if showOnlyInFullScreen {
            msgInfo.showOnlyInFullScreen = showOnlyInFullScreen
        } else if msgInfo.msgSize > XNUIConstants.msgCellMaxAllowedSize {
            // Data size is too large, cannot be displayed in cell.
            msgInfo.showOnlyInFullScreen = true
        }
        messages.append(msgInfo)
    }
}
