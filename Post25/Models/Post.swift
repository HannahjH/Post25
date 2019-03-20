//
//  Post.swift
//  Post25
//
//  Created by Hannah Hoff on 3/18/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation

// Add properties on Post
struct Post: Codable {
    let timestamp: TimeInterval
    let text: String
    let username: String
    
    // Memberwise Initializer
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
    // Add a computed property queryTimestamp to the Post type that returns a timeinterval adjusted by  0.00001 from the self.timestamp
    var queryTimestamp: TimeInterval {
        return self.timestamp - 0.00001
    }
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case text = "text"
        case timestamp = "timestamp"
    }
}

