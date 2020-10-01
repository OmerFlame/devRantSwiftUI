//
//  View+Extension.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/15/20.
//

import SwiftUI

extension View {
    func onFrameChange(enabled isEnabled: Bool = true, frameHandler: @escaping (CGRect) -> ()) -> some View {
        guard isEnabled else { return AnyView(self) }
        return AnyView(self.background(GeometryReader { (geometry: GeometryProxy) in
            Color.clear.beforeReturn {
                frameHandler(geometry.frame(in: .global))
            }
        }))
    }
    
    private func beforeReturn(_ onBeforeReturn: () -> ()) -> Self {
        onBeforeReturn()
        return self
    }
}

extension View {
    var embeddedInNavigationLink: some View {
        NavigationLink(
            destination: CollectionDetailView(contentView: self),
            label: {
                self
            }).buttonStyle(PlainButtonStyle())
    }
    
}
