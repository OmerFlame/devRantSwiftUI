//
//  RantFeed.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/1/20.
//

import Foundation
import SwiftUI
import Combine

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
    var rants: [RantInFeed]?
    
    let settings: RantFeedSettings?
    
    let set: String?
    let wrw: Int?
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
    
    init(success: Bool,
         rants: [RantInFeed]?,
         settings: RantFeedSettings?,
         set: String?,
         wrw: Int?,
         dpp: Int?,
         num_notifs: Int?,
         unread: RantFeedUnread?,
         news: RantFeedNews?) {
        
        self.success = success
        self.rants = rants
        self.settings = settings
        self.set = set
        self.wrw = wrw
        self.dpp = dpp
        self.num_notifs = num_notifs
        self.unread = unread
        self.news = news
    }
    
    mutating func addRantsToRantFeed(newRants: [RantInFeed]) {
        self.rants!.append(contentsOf: newRants)
    }
}

class RantFeedObservable: ObservableObject {
    @Published var rants = [RantInFeed]()
    @Published var isLoadingPage = false
    
    init() {
        loadMoreContent()
    }
    
    func loadMoreContentIfNeeded(currentItem item: RantInFeed?) {
        guard let item = item else {
            loadMoreContent()
            return
        }
        
        print("ARRAY LENGTH: \(rants.count)")
        
        let thresholdIndex = rants.index(rants.endIndex, offsetBy: -1)
        print("THRESHOLD INDEX: \(thresholdIndex)")
        
        if rants.firstIndex(where: { $0.uuid == item.uuid }) == thresholdIndex {
            loadMoreContent()
        }
        
    }
    
    private func loadMoreContent() {
        guard !isLoadingPage else {
            return
        }
        
        isLoadingPage = true
        
        if Double(UserDefaults.standard.integer(forKey: "TokenExpireTime")) - Date().timeIntervalSince1970 <= 0 {
            APIRequest().logIn(username: UserDefaults.standard.string(forKey: "Username")!, password: UserDefaults.standard.string(forKey: "Password")!)
        }
        
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://devrant.com/api/devrant/rants?app=3&token_id=\(String(UserDefaults.standard.integer(forKey: "TokenID")))&token_key=\(UserDefaults.standard.string(forKey: "TokenKey")!)&user_id=\(String(UserDefaults.standard.integer(forKey: "UserID")))&range=week&limit=20")!)
            .map(\.data)
            .decode(type: RantFeed.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.isLoadingPage = false
            })
            .map({ response in
                return self.rants + response.rants!
            })
            .catch({ _ in Just(self.rants) })
            .assign(to: &$rants)
    }
}
