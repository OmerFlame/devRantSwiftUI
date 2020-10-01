//
//  RantFeed.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/1/20.
//

import Foundation

struct RantFeed: Codable {
    struct RantFeedSettings: Codable {
        let notif_state: String
        let notif_token: String?
    }
    
    struct RantFeedUnread: Codable {
        let total: Int
    }
    
    struct RantFeedNews: Codable {
        let id: Int
        let type: String
        let headline: String
        let body: String
        let footer: String
        let height: Int
        let action: RantFeedNewsAction
    }
    
    enum RantFeedNewsAction: String, Codable {
        case groupRant = "grouprant"
        case none = "none"
        case rant = "rant"
    }
    
    let success: Bool
    let rants: [RantInFeed]
    let settings: RantFeedSettings
    
    let set: String
    let wrw: Int
    let dpp: Int?
    
    let num_notifs: Int
    let unread: RantFeedUnread
    let news: RantFeedNews?
}
