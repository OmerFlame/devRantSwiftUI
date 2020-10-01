//
//  GeometryContainer.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/14/20.
//

import SwiftUI

struct GeometryContainer: View {
    @State var frame: CGSize = .zero
    var viewToWrap: AnyView
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                makeView(geometry, viewToWrap: self.viewToWrap)
            }
        }
    }
    
    func makeView(_ geometry: GeometryProxy, viewToWrap: AnyView) -> some View {
        DispatchQueue.main.async {
            self.frame = geometry.size
        }
        
        return viewToWrap.frame(height: geometry.size.height)
    }
}
