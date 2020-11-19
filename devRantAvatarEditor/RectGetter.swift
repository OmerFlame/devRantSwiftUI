//
//  RectGetter.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 11/11/20.
//

import SwiftUI

// The purpose of this view is to quickly and easily get the frame of any SwiftUI view by using this view as a background.
// This is useful for sharing compatible SwiftUI rect data with UIKit UIViews or UIViewControllers without interrupting normal SwiftUI operations.

struct RectGetter: View {
    @Binding var rect: CGRect
    @State public var proxy: GeometryProxy? = nil
    
    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
            self.proxy = Optional(proxy)
        }
        
        return Rectangle().fill(Color.clear)
    }
    
    public func getRect(proxy: GeometryProxy) -> CGRect {
        return proxy.frame(in: .global)
    }
}
