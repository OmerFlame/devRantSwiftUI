//
//  Comment.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/14/20.
//

import Foundation

struct CommentModel: Codable, Identifiable {
    var uuid = UUID()
    
    let id: Int
    let rant_id: Int
    let body: String
    let score: Int
    let created_time: Int
    let vote_state: Int
    let links: [Link]?
    let user_id: Int
    let user_username: String
    let user_score: Int
    let user_avatar: UserAvatar
    let user_dpp: Int?
    let attached_image: AttachedImage?
    
    private enum CodingKeys: String, CodingKey {
        case id,
             rant_id,
             body,
             score,
             created_time,
             vote_state,
             links,
             user_id,
             user_username,
             user_score,
             user_avatar,
             user_dpp,
             attached_image
    }
    
    public init(decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        rant_id = try values.decode(Int.self, forKey: .rant_id)
        body = try values.decode(String.self, forKey: .body)
        score = try values.decode(Int.self, forKey: .score)
        created_time = try values.decode(Int.self, forKey: .created_time)
        vote_state = try values.decode(Int.self, forKey: .vote_state)
        links = try? values.decode([Link].self, forKey: .links)
        user_id = try values.decode(Int.self, forKey: .user_id)
        user_username = try values.decode(String.self, forKey: .user_username)
        user_score = try values.decode(Int.self, forKey: .user_score)
        user_avatar = try values.decode(UserAvatar.self, forKey: .user_avatar)
        user_dpp = try? values.decode(Int.self, forKey: .user_dpp)
        attached_image = try? values.decode(AttachedImage.self, forKey: .attached_image)
    }
}
