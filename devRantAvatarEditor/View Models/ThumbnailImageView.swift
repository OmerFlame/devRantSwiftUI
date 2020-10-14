//
//  ThumbnailImageView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/14/20.
//

import SwiftUI
import QuickLook

struct ThumbnailImageView: View {
    let url: URL
    let size: CGSize

    @State private var thumbnail: CGImage? = nil

    var body: some View {
        Group {
            if thumbnail != nil {
                Image(uiImage: UIImage(cgImage: self.thumbnail!))
                    .resizable()
                    .frame(width: self.size.width, height: self.size.height)
            } else {
                Image(systemName: "photo") // << any placeholder
                    .resizable()
                    .onAppear {
                        self.generateThumbnail(ofThis: "")
                    }
            }
        }
    }

    func generateThumbnail(ofThis: String) {
        //let size: CGSize = CGSize(width: 68, height: 88)
        let request = QLThumbnailGenerator.Request(fileAt: url, size: self.size, scale: (UIScreen.main.scale), representationTypes: .thumbnail)
        let generator = QLThumbnailGenerator.shared

        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil {
                    print(url)
                    
                    print(error!.localizedDescription)
                    assert(false, "Thumbnail failed to generate")
                } else {
                    DispatchQueue.main.async { // << required !!
                        self.thumbnail = thumbnail!.cgImage  // here !!
                    }
                }
            }
        }
    }
}
