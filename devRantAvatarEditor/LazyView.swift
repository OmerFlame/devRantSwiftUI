//
//  LazyView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 11/17/20.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
