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
    @Binding var rantInFeed: RantInFeed
    let userImage: UIImage?
    let profile: Profile
    @State var shouldShowError = false
    
    @State var url = URL(string: "")
    
    var body: some View {
        HStack {
            VStack {
                HStack(alignment: .top) {
                    VStack {
                        Button(action: {
                            let success = APIRequest().voteOnRant(rantID: self.rantContents.id, vote: 1)
                            
                            if !success {
                                self.shouldShowError.toggle()
                            } else {
                                self.rantContents.vote_state = 1
                            }
                            
                            self.rantInFeed.vote_state = 1
                        }, label: {
                                if self.rantContents.vote_state == 1 {
                                Image(systemName: "plus.circle.fill").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                            } else if self.rantContents.vote_state == 0 {
                                Image(systemName: "plus.circle.fill").accentColor(.gray).font(.system(size: 25))
                            } else {
                                Image(systemName: "plus.circle.fill").disabled(true).font(.system(size: 25))
                            }
                        })
                        Text(String(self.rantContents.score)).font(.subheadline)
                        Button(action: {
                            let success = APIRequest().voteOnRant(rantID: self.rantContents.id, vote: -1)
                            
                            if !success {
                                self.shouldShowError.toggle()
                            } else {
                                self.rantContents.vote_state = -1
                            }
                        }, label: {
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
                        /*HStack {
                            if self.rantContents.user_avatar.i == nil {
                                let color = UIColor(hex: self.rantContents.user_avatar.b)
                                
                                Circle()
                                    .size(CGSize(width: 45, height: 45))
                                    .fill(Color(color!))
                                    .frame(width: 45, height: 45)
                                    //.padding(.trailing)
                                
                                VStack(alignment: .leading, spacing: 1.0) {
                                    Text(self.rantContents.user_username)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .scaledToFill()
                                    
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 5).fill(Color(color!))
                                        Text("+" + String(self.rantContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                    }.fixedSize()
                                }.scaledToFit()
                                
                                Spacer()
                            } else {
                                ImageView(withURL: "https://avatars.devrant.com/" + self.rantContents.user_avatar.i!, width: 45, height: 45)
                                        .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 1.0) {
                                    Text(self.rantContents.user_username).fixedSize(horizontal: false, vertical: true).scaledToFill()
                                        
                                    ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 5).fill(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                        Text("+" + String(self.rantContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                    }.fixedSize()
                                }.scaledToFit()
                                
                                
                                Spacer()
                            }
                        }*/
                        
                        NavigationLink(
                            destination: /*ProfileInfiniteScrollViewRepresentable(userID: self.rantContents.user_id).edgesIgnoringSafeArea(.top)*/ //SecondaryProfileRepresentable(userID: self.rantContents.user_id)
                                TertiaryProfileScrollSwiftUI(userID: self.rantContents.user_id, profileData: self.profile, image: self.userImage)
                                .edgesIgnoringSafeArea(.top),
                            label: {
                                HStack {
                                    if self.rantContents.user_avatar.i == nil {
                                        let color = UIColor(hex: self.rantContents.user_avatar.b)
                                        
                                        Circle()
                                            .size(CGSize(width: 45, height: 45))
                                            .fill(Color(color!))
                                            .frame(width: 45, height: 45)
                                            //.padding(.trailing)
                                        
                                        VStack(alignment: .leading, spacing: 1.0) {
                                            Text(self.rantContents.user_username)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .scaledToFill()
                                            
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 5).fill(Color(color!))
                                                Text("+" + String(self.rantContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                            }.fixedSize()
                                        }.scaledToFit()
                                        
                                        Spacer()
                                    } else {
                                        ImageView(withURL: "https://avatars.devrant.com/" + self.rantContents.user_avatar.i!, width: 45, height: 45)
                                                .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 1.0) {
                                            Text(self.rantContents.user_username)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .scaledToFill()
                                                
                                            ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 5).fill(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                                Text("+" + String(self.rantContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.black)
                                            }.fixedSize()
                                        }.scaledToFit()
                                        
                                        
                                        Spacer()
                                    }
                                }
                            }
                        ).buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            Text(self.rantContents.text)
                                .padding(.trailing)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading) {
                            if self.rantContents.attached_image != nil {
                                let resizeMultiplier = self.getImageResizeMultiplier(
                                    imageWidth: CGFloat(self.rantContents.attached_image!.width!),
                                    imageHeight: CGFloat(self.rantContents.attached_image!.height!), multiplier: 1)
                                
                                let url = File.loadFiles(images: [self.rantContents.attached_image!])[0].url
                                
                                HStack {
                                    //QLView(attachedImage: self.rantContents.attached_image!)
                                    SecondaryQLView(attachedImage: self.rantContents.attached_image!, pendingURL: url)
                                    /*TertiaryQLView(attachedImage: AttachedImage(
                                                    url: "https://img.devrant.com/devrant/rant/r_3240155_Re4L3.jpg",
                                                    width: 491,
                                                    height: 487))*/
                                    
                                    Spacer()
                                }
                                
                                
                            }
                            
                            TagCloudView(tags: self.rantContents.tags, color: Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                            Divider()
                        }
                        
                        
                    }
                        //Spacer()
                }.padding([.leading, .top]).fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
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
