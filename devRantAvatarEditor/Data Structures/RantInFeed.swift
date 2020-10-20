//
//  RantInFeed.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/25/20.
//

import Foundation

public struct RantInFeed: Codable, Identifiable {
    let uuid = UUID()
    
    public let id: Int
    let text: String
    let score: Int
    let created_time: Int
    let attached_image: Polytype
    let num_comments: Int
    let tags: [String]
    let vote_state: Int
    let edited: Bool
    let link: String?
    
    let rt: Int?
    let rc: Int?
    
    let c_type: Int?
    let c_type_long: String?
    
    let user_id: Int
    let user_username: String
    let user_score: Int
    let user_avatar: UserAvatar
    let user_avatar_lg: UserAvatar
    let user_dpp: Int?
    
    enum CodingKeys: String, CodingKey {
        case id,
             text,
             score,
             created_time,
             attached_image,
             num_comments,
             tags,
             vote_state,
             edited,
             link,
             rt,
             rc,
             c_type,
             c_type_long,
             user_id,
             user_username,
             user_score,
             user_avatar,
             user_avatar_lg,
             user_dpp
    }
}
