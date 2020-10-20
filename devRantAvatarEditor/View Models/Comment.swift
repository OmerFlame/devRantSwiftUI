//
//  Comment.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/14/20.
//

import SwiftUI

public struct Comment: View {
    let highlightColor: Color
    @State var commentContents: CommentModel
    
    public var body: some View {
        HStack {
            VStack {
                HStack(alignment: .top) {
                    VStack {
                        Button(action: {}, label: {
                                if self.commentContents.vote_state == 1 {
                                Image(systemName: "plus.circle.fill").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.commentContents.user_avatar.b)!))
                            } else if self.commentContents.vote_state == 0 {
                                Image(systemName: "plus.circle.fill").accentColor(.gray).font(.system(size: 25))
                            } else {
                                Image(systemName: "plus.circle.fill").font(.system(size: 25))
                            }
                        }).disabled(self.commentContents.vote_state == -2)
                        Text(String(self.commentContents.score)).font(.subheadline)
                        Button(action: {}, label: {
                            if self.commentContents.vote_state == -1 {
                                Image(systemName: "minus.circle.fill").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.commentContents.user_avatar.b)!))
                            } else if self.commentContents.vote_state == 0 {
                                Image(systemName: "minus.circle.fill").accentColor(.gray).font(.system(size: 25))
                            } else {
                                Image(systemName: "minus.circle.fill").accentColor(.gray).font(.system(size: 25))
                            }
                        }).disabled(self.commentContents.vote_state == -2)
                    }
                    
                    
                    //.scaledToFill()
                    
                    VStack {
                        NavigationLink(
                            
                            destination: ProfileView(userID: self.commentContents.user_id),
                            label: {
                                HStack {
                                    if self.commentContents.user_avatar.i == nil {
                                        let color = UIColor(hex: self.commentContents.user_avatar.b)
                                        
                                        Circle()
                                            .size(CGSize(width: 45, height: 45))
                                            .fill(Color(color!))
                                            .frame(width: 45, height: 45)
                                            //.padding(.trailing)
                                        
                                        VStack(alignment: .leading, spacing: 1.0) {
                                            Text(self.commentContents.user_username)
                                                .fixedSize(horizontal: true, vertical: false)
                                                //.scaledToFill()
                                            
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 5).fill(Color(color!))
                                                Text("+" + String(self.commentContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                            }.fixedSize()
                                        }.scaledToFit()
                                        
                                        Spacer()
                                    } else {
                                        ImageView(withURL: "https://avatars.devrant.com/" + self.commentContents.user_avatar.i!, width: 45, height: 45)
                                                .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 1.0) {
                                            Text(self.commentContents.user_username).fixedSize(horizontal: false, vertical: true).fixedSize(horizontal: true, vertical: false)
                                                
                                            ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 5).fill(Color(UIColor(hex: self.commentContents.user_avatar.b)!))
                                                Text("+" + String(self.commentContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                            }.fixedSize()
                                        }.scaledToFit()
                                        
                                        
                                        Spacer()
                                    }
                                }
                            }
                        ).buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            Text(self.commentContents.body)
                                .padding(.trailing)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        
                        if self.commentContents.attached_image != nil {
                            let resizeMultiplier = self.getImageResizeMultiplier(
                                imageWidth: CGFloat(self.commentContents.attached_image!.width!),
                                imageHeight: CGFloat(self.commentContents.attached_image!.height!), multiplier: 1)
                            
                            let url = File.loadFiles(images: [self.commentContents.attached_image!])[0].url
                            
                            HStack {
                                SecondaryQLView(attachedImage: self.commentContents.attached_image!, pendingURL: url)
                                
                                Spacer()
                            }
                        }
                        
                        Divider()
                    }
                        
                        //Spacer()
                }.padding([.leading, .top])//.fixedSize(horizontal: false, vertical: true)
            }
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

struct Comment_Previews: PreviewProvider {
    static var previews: some View {
        Comment(highlightColor: Color.red,
                commentContents: CommentModel(
                    id: 3290854,
                    rant_id: 3290301,
                    body: "Senior dev: It'd better be Liit",
                    score: 0,
                    created_time: 1603125848,
                    vote_state: 0,
                    links: nil,
                    user_id: 3290286,
                    user_username: "ashinsiider",
                    user_score: 1,
                    user_avatar: UserAvatar(
                        b: "7bc8a4",
                        //i: "v-37_c-3_b-2_g-m_9-1_1-6_16-4_3-6_8-4_7-4_5-4_12-6_17-2_6-15_2-26_22-7_15-3_11-3_18-4_19-4_4-4_20-1_21-1.jpg"
                        i: nil
                    ),
                    user_dpp: nil,
                    attached_image: nil /*AttachedImage(
                        url: "https://avatars.devrant.com/v-37_c-1_b-5_g-m_9-1_1-1_16-7_3-2_8-2_7-2_5-1_12-1_6-97_10-9_2-90_22-7_11-8_18-3_19-2_4-1_20-2.png",
                        width: 1400,
                        height: 1400)*/
                ))
    }
}
