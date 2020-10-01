//
//  Comment.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/14/20.
//

import Foundation

struct CommentModel: Codable, Identifiable {
    let uuid = UUID()
    
    let id: Int
    let rant_id: Int
    let body: String
    let score: Int
    let created_time: Int
    let vote_state: Int
    let user_id: Int
    let user_username: String
    let user_avatar: UserAvatar
    
    private enum CodingKeys: String, CodingKey {
        case id,
             rant_id,
             body,
             score,
             created_time,
             vote_state,
             user_id,
             user_username,
             user_avatar
    }
}
