//
//  RantStructure.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import Foundation

public struct RantModel: Codable, Identifiable {
    public let uuid = UUID()
    
    public struct Link: Codable {
        let type: String
        let url: String
        let short_url: String
        let title: String
        let start: Int
        let end: Int
        let special: Int
    }
    
    
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
    
    let rt: Int
    let rc: Int
    
    let links: [Link]?
    
    let special: Int?
    
    let c_type_long: String?
    let c_description: String?
    let c_tech_stack: String?
    let c_team_size: String?
    let c_url: String?
    
    let user_id: Int
    let user_username: String
    let user_score: Int
    
    let user_avatar: UserAvatar
    let user_avatar_lg: UserAvatar
    
    let user_dpp: Int?
    
    let comments: [CommentModel?]
    
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
             links,
             special,
             c_type_long,
             c_description,
             c_tech_stack,
             c_team_size,
             c_url,
             user_id,
             user_username,
             user_score,
             user_avatar,
             user_avatar_lg,
             user_dpp,
             comments
    }
}

enum Polytype: Codable {
    case string(String)
    case attachedImage(AttachedImage)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(AttachedImage.self) {
            self = .attachedImage(x)
            return
        }
        throw DecodingError.typeMismatch(Polytype.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Polytype"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
            
        case .attachedImage(let x):
            try container.encode(x)
        }
    }
}

struct AttachedImage: Codable {
    //let attached_image: String?
    
    let url: String?
    let width: Int?
    let height: Int?
}

struct UserAvatar: Codable {
    let b: String
    let i: String?
}
