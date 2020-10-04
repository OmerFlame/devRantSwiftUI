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
    let settings: RantFeedSettings?
    
    let set: String
    let wrw: Int
    let dpp: Int?
    
    let num_notifs: Int?
    let unread: RantFeedUnread?
    let news: RantFeedNews?
    
    private enum CodingKeys: String, CodingKey {
        case success,
             rants,
             settings,
             set,
             wrw,
             dpp,
             num_notifs,
             unread,
             news
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = try values.decode(Bool.self, forKey: .success)
        rants = try values.decode([RantInFeed].self, forKey: .rants)
        settings = try? values.decode(RantFeedSettings.self, forKey: .settings)
        set = try values.decode(String.self, forKey: .set)
        wrw = try values.decode(Int.self, forKey: .wrw)
        dpp = try? values.decode(Int.self, forKey: .dpp)
        num_notifs = try? values.decode(Int.self, forKey: .num_notifs)
        unread = try? values.decode(RantFeedUnread.self, forKey: .unread)
        news = try? values.decode(RantFeedNews.self, forKey: .news)
    }
}
