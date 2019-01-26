//
//  NLSlackUser.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 18/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public struct NLSlackUser {
    
    let token: String
    let username: String
    let channel: String
    
    public init(token: String, username: String, channel: String) {
        self.token = token
        self.username = username
        self.channel = channel
    }
    
}
