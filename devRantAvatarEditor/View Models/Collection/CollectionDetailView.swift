//
//  SwiftUIView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/15/20.
//

import SwiftUI

struct CollectionDetailView<Content>: View where Content: View {
    var contentView: Content
    
    var body: some View {
        contentView
    }
}
