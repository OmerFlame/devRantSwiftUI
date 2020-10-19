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
    
    @State var url = URL(string: "")
    
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
                            destination: ProfileView(userID: self.rantContents.user_id),
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
                                            Text(self.rantContents.user_username).fixedSize(horizontal: false, vertical: true).scaledToFill()
                                                
                                            ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 5).fill(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                                Text("+" + String(self.rantContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
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
        if imageWidth / CGFloat(multiplier) < UIScreen.main.bounds.width && imageHeight / CGFloat(multiplier) < UIScreen.main.bounds.height {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}

struct Rant_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            Rant(
                rantContents: RantModel(
                    id: 3235636,
                    text: "It is about time we start thinking of real alternatives to JS in the browser.\n\nWhat is wrong with TKinter on the web?\nJavaFX? Even Windows Forms dude!\n\nI am sick of the darn following:\n- Webpack, Parcel\n- React, Angular, Vue\n- Typescript, babel\n- Polyfills\n- undefined\n- COMPAFUCKINGBILITY!\n- SPA VS. MPA\n- SEO\n- Maintainability\n- BlaBla does not have a constructor\n- <any>\n\nI AM SICK OF WORKAROUNDS TO A ROOT PROBLEM WITHOUT BATTING AN EYE ABOUT THE ROOT PROBLEM!\nLEARNING THE SHIT TON OF TOOLING FOR A MONTH BEFORE DOING ONE THING SHOULDN'T BE THE CASE! FUCK!",
                    score: 5,
                    created_time: 1602542137,
                    attached_image: AttachedImage(
                        url: "https://img.devrant.com/devrant/rant/r_3240155_Re4L3.jpg",
                        width: 491,
                        height: 487),
                    num_comments: 20,
                    tags: [
                        "rant",
                        "web",
                        "typescript",
                        "js",
                        "tools",
                        "problem solving",
                        "babel",
                        "javascript"
                    ],
                    vote_state: 0,
                    edited: false,
                    link: "rants/3235636/it-is-about-time-we-start-thinking-of-real-alternatives-to-js-in-the-browser-wha",
                    rt: 1,
                    rc: 1,
                    links: nil,
                    special: nil,
                    c_type_long: nil,
                    c_description: nil,
                    c_tech_stack: nil,
                    c_team_size: nil,
                    c_url: nil,
                    user_id: 2522098,
                    user_username: "aj7397",
                    user_score: 565,
                    user_avatar: UserAvatar(
                        b: "2a8b9d",
                        i: "v-37_c-3_b-4_g-m_9-1_1-11_16-3_3-2_8-1_7-1_5-1_12-11_17-1_6-2_10-4_2-39_22-1_15-2_11-1_18-1_4-1.jpg"
                        //i: nil
                    ),
                    user_avatar_lg: UserAvatar(
                        b: "2a8b9d",
                        i: "v-37_c-1_b-4_g-m_9-1_1-11_16-3_3-2_8-1_7-1_5-1_12-11_17-1_6-2_10-4_2-39_22-1_15-2_11-1_18-1_4-1.png"
                    ),
                    user_dpp: nil,
                    comments: nil
            ))
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
