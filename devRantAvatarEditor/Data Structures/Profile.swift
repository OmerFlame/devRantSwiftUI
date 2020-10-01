//
//  Profile.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/25/20.
//

import Foundation

struct Profile: Codable {
    let username: String
    let score: Int
    let about: String
    let location: String
    let created_time: Int
    let skills: String
    let github: String
    let website: String
    let content: UserContent
    let counts: UserCounts
    let avatar: UserAvatar
    let avatar_sm: UserAvatar
    let dpp: Int?
}

struct UserContent: Codable {
    let rants: [RantInFeed]
    let upvoted: [RantInFeed]
    let comments: [CommentModel]
    let favorites: [RantInFeed]
}

struct UserCounts: Codable {
    let rants: Int
    let upvoted: Int
    let comments: Int
    let favorite: Int
    let collabs: Int
}
