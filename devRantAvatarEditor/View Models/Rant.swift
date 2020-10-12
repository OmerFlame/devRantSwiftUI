//
//  Rant.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI
import Combine

struct Rant: View {
    @State var shouldShowLoadingRing = true
    @State var rantContents: RantModel
    
    var body: some View {
        HStack {
            VStack {
                HStack(alignment: .top) {
                    VStack {
                        Button(action: {}, label: {
                                if self.rantContents.vote_state == 1 {
                                Image(systemName: "plus.circle.fill").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                            } else if self.rantContents.vote_state == 0 {
                                Image(systemName: "plus.circle.fill").accentColor(.gray).font(.system(size: 25))
                            } else {
                                Image(systemName: "plus.circle.fill").disabled(true).font(.system(size: 25))
                            }
                        })
                        Text(String(self.rantContents.score)).font(.subheadline)
                        Button(action: {}, label: {
                            if self.rantContents.vote_state == -1 {
                                Image(systemName: "minus.circle.fill").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                            } else if self.rantContents.vote_state == 0 {
                                Image(systemName: "minus.circle.fill").accentColor(.gray).font(.system(size: 25))
                            } else {
                                Image(systemName: "minus.circle.fill").disabled(true).font(.system(size: 25))
                            }
                        })
                    }
                    
                    
                    //.scaledToFill()
                    
                    VStack {
                        HStack {
                            if self.rantContents.user_avatar.i == nil {
                                let color = UIColor(hex: self.rantContents.user_avatar.b)
                                    
                                    
                                Circle()
                                    .size(CGSize(width: 45, height: 45))
                                    .fill(Color(color!))
                            } else {
                                ImageView(withURL: "https://avatars.devrant.com/" + self.rantContents.user_avatar.i!, width: 45, height: 45)
                                        .clipShape(Circle())
                                    
                                VStack(alignment: .leading, spacing: -1.0) {
                                    Text(self.rantContents.user_username).fixedSize(horizontal: false, vertical: true).scaledToFill()
                                        
                                    ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 5).fill(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                        Text("+" + String(self.rantContents.user_score)).colorInvert().padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption)
                                    }.fixedSize()
                                }.scaledToFit()
                                
                                
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Text(self.rantContents.text)
                                .padding(.trailing)
                            
                            Spacer()
                        }
                        
                        
                        
                        VStack(alignment: .leading) {
                            if self.rantContents.attached_image != nil {
                                
                                QLView(attachedImage: self.rantContents.attached_image!)
                                    /*.frame(
                                        width: CGFloat(self.rantContents.attached_image!.width!) / CGFloat(resizeMultiplier),
                                        height: CGFloat(self.rantContents.attached_image!.width!) / CGFloat(resizeMultiplier))*/
                            }
                            
                            TagCloudView(tags: self.rantContents.tags, color: Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                            Divider()
                        }
                    }
                        
                        //Spacer()
                }.padding([.leading, .top])//.fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> Int {
        if imageWidth / CGFloat(multiplier) < 420.0 && imageHeight / CGFloat(multiplier) < 315.0 {
            return multiplier
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 1)
        }
    }
}


class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()
    var width: CGFloat
    var height: CGFloat
    
    init(withURL url: String, width: CGFloat, height: CGFloat) {
        imageLoader = ImageLoader(urlString: url)
        self.width = width
        self.height = height
    }
    
    var body: some View {
        Image(uiImage: self.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .scaledToFit()
            .frame(width: self.width, height: self.height)
            .onReceive(imageLoader.didChange) { data in
                self.image = UIImage(data: data) ?? UIImage()
        }
    }
}
