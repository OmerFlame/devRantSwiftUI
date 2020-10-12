//
//  RantResponse.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/12/20.
//

import Foundation

struct RantResponse: Codable {
    let rant: RantModel
    
    let comments: [CommentModel]
    
    let success: Bool
}
