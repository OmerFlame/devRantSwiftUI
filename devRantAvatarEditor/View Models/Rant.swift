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
                
            //Spacer()
                
            VStack(alignment: .leading) {
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
                            
                        //Spacer()
                    }
                        
                    //Spacer()
                        
                }//.frame(width: geometry.size.width, alignment: .leading)
                .scaledToFill()
                    
                    
                    
                VStack(alignment: .leading) {
                    HStack {
                        Text(self.rantContents.text)
                            //.padding(.leading)
                            .font(.body)
                                //.lineLimit(100)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .fixedSize(horizontal: false, vertical: true)
                            
                            .layoutPriority(1)
                        
                        Spacer()
                    }
                        
                        
                        
                        //.frame(alignment: .leading)
                        
                    
                        
                    HStack {
                        ForEach(self.rantContents.tags, id: \.self) { tag in
                            Text(tag).font(.footnote).underline()
                        }
                            
                        Spacer()
                    }
                }.scaledToFit().frame(minWidth: 0, maxWidth: .infinity)
                    
                Divider()
                    
                    //Spacer()
            }//.padding([]) // END VSTACK
                
                //Spacer()
        }.padding([.leading, .top]).fixedSize(horizontal: false, vertical: true)
            //.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
    //.padding(.top).fixedSize(horizontal: false, vertical: false)
    }
}

struct Rant_Previews: PreviewProvider {
    static var previews: some View {
        Rant(rantContents: RantModel(id: 327111,
                                     text: "My girlfriend got me this mug. She is the one.sdfgsdfg",
                                     score: 157,
                                     created_time: 1481230115,
                                     attached_image: .attachedImage(AttachedImage(
                                        url: "https://img.devrant.com/devrant/rant/r_327111_pMWmu.jpg",
                                        width: 562,
                                        height: 1000
                                     )),
                                     num_comments: 1,
                                     tags: ["undefined", "linus", "torvalds", "mug"],
                                     vote_state: 0,
                                     edited: false,
                                     link: "rants/327111/my-girlfriend-got-me-this-mug-shes-the-one",
                                     rt: 1,
                                     rc: 7,
                                     links: nil,
                                     special: nil,
                                     c_type_long: nil,
                                     c_description: nil,
                                     c_tech_stack: nil,
                                     c_team_size: nil,
                                     c_url: nil,
                                     user_id: 118128,
                                     user_username: "blackmarket",
                                     user_score: 5885,
                                     user_avatar: UserAvatar(
                                        b: "d55161",
                                        i: "v-37_c-3_b-5_g-m_9-1_1-1_16-2_3-6_8-4_7-4_5-4_12-1_6-3_10-1_2-41_22-1_15-5_18-4_19-3_4-4_20-10.jpg"
                                     ),
                                     user_avatar_lg: UserAvatar(
                                        b: "d55161",
                                        i: "v-37_c-1_b-5_g-m_9-1_1-1_16-2_3-6_8-4_7-4_5-4_12-1_6-3_10-1_2-41_22-1_15-5_18-4_19-3_4-4_20-10.png"
                                     ),
                                     user_dpp: nil,
                                     comments: [
                                        CommentModel(id: 327120,
                                                rant_id: 327111,
                                                body: "Wow its picture where torvalds show fuck off to nvidia cool",
                                                score: 8,
                                                created_time: 1481230451,
                                                vote_state: 0,
                                                user_id: 19218,
                                                user_username: "Haxk20",
                                                user_avatar: UserAvatar(
                                                    b: "7bc8a4",
                                                    i: "v-37_c-3_b-1_g-m_9-2_1-2_16-14_3-3_8-3_7-3_5-4_12-2_6-3_10-1_2-109_22-1_18-4_19-5_4-4_20-15_21-4.jpg"
                                                ))
                                     ])
    )
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
