//
//  Comment.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/14/20.
//

import SwiftUI

/*public struct Comment: View {
    
    let highlightColor: Color
    @State var commentContents: CommentModel
        
    public var body: some View {
        HStack(alignment: .top) {
            VStack {
                Button(action: {}, label: {
                    if self.commentContents.vote_state == 1 {
                        Image(systemName: "plus.circle.fill").font(.system(size: 25)).accentColor(self.highlightColor)
                    } else if self.commentContents.vote_state == 0 {
                        Image(systemName: "plus.circle.fill").accentColor(.gray).font(.system(size: 25))
                    } else {
                        Image(systemName: "plus.circle.fill").disabled(true).font(.system(size: 25))
                    }
                })
                Text(String(self.commentContents.score)).font(.subheadline)
                Button(action: {}, label: {
                    if self.commentContents.vote_state == -1 {
                        Image(systemName: "minus.circle.fill").font(.system(size: 25)).accentColor(self.highlightColor)
                    } else if self.commentContents.vote_state == 0 {
                        Image(systemName: "minus.circle.fill").accentColor(.gray).font(.system(size: 25))
                    } else {
                        Image(systemName: "minus.circle.fill").disabled(true).font(.system(size: 25))
                    }
                })
            }
                    
            //Spacer()
                    
            VStack(alignment: .leading) {
                HStack {
                    if self.commentContents.user_avatar.i == nil {
                        let color = UIColor(hex: self.commentContents.user_avatar.b)
                        
                                
                                
                        Circle()
                            .size(CGSize(width: 45, height: 45))
                            .fill(Color(color!))
                    } else {
                        ImageView(withURL: "https://avatars.devrant.com/" + self.commentContents.user_avatar.i!, width: 45, height: 45)
                                .clipShape(Circle())
                                
                        VStack(alignment: .leading, spacing: -1.0) {
                            Text(self.commentContents.user_username).fixedSize().scaledToFit()
                                    
                            ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5).fill(self.highlightColor)
                                Text("+" + String(self.commentContents.user_score)).colorInvert().padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption)
                            }.fixedSize()
                                    
                        }.scaledToFit()
                                
                            //Spacer()
                    }
                            
                        //Spacer()
                            
                }//.frame(width: geometry.size.width, alignment: .leading)
                .scaledToFill()
                        
                        
                        
                VStack(alignment: .leading) {
                    Text(self.commentContents.body)
                        //.padding(.leading)
                        .font(.body)
                        //.lineLimit(100)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        //.frame(alignment: .leading)
                        //.scaledToFill()
                        .layoutPriority(1)
                            
                            
                            
                        //.frame(alignment: .leading)
                            
                    //Spacer()
                }.scaledToFit().frame(minWidth: 0, maxWidth: .infinity)
                        
                Divider()
                        
                //Spacer()
            }.padding([]) // END VSTACK
                    
            Spacer()
        }.padding([.leading]).fixedSize(horizontal: false, vertical: true)//.padding([.leading])
        //.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
    }
}
*/

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
                                Image(systemName: "plus.circle.fill").disabled(true).font(.system(size: 25))
                            }
                        })
                        Text(String(self.commentContents.score)).font(.subheadline)
                        Button(action: {}, label: {
                            if self.commentContents.vote_state == -1 {
                                Image(systemName: "minus.circle.fill").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.commentContents.user_avatar.b)!))
                            } else if self.commentContents.vote_state == 0 {
                                Image(systemName: "minus.circle.fill").accentColor(.gray).font(.system(size: 25))
                            } else {
                                Image(systemName: "minus.circle.fill").disabled(true).font(.system(size: 25))
                            }
                        })
                    }
                    
                    
                    //.scaledToFill()
                    
                    VStack {
                        HStack {
                            if self.commentContents.user_avatar.i == nil {
                                let color = UIColor(hex: self.commentContents.user_avatar.b)
                                
                                Circle()
                                    .size(CGSize(width: 45, height: 45))
                                    .fill(Color(color!))
                                    .frame(width: 45, height: 45)
                                    //.padding(.trailing)
                                
                                VStack(alignment: .leading, spacing: 1.0) {
                                    Text(self.commentContents.user_username).fixedSize(horizontal: false, vertical: true)
                                        .scaledToFill()
                                    
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
                                    Text(self.commentContents.user_username)
                                        .fixedSize()
                                        .scaledToFill()
                                        .frame(alignment: .leading)
                                        
                                    ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 5).fill(Color(UIColor(hex: self.commentContents.user_avatar.b)!))
                                        Text("+" + String(self.commentContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                    }.fixedSize()
                                }.scaledToFit()
                                
                                
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Text(self.commentContents.body)
                                .padding(.trailing)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        
                        if self.commentContents.attached_image != nil {
                            HStack {
                                QLView(attachedImage: self.commentContents.attached_image!)
                                
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
}

struct Comment_Previews: PreviewProvider {
    static var previews: some View {
        Comment(highlightColor: Color.red,
                commentContents: CommentModel(
                    id: 11111,
                    rant_id: 99999,
                    body: "Test Test Test Test",
                    score: 9000,
                    created_time: 2350498723,
                    vote_state: 0,
                    links: nil,
                    user_id: 34598735,
                    user_username: "OmerFlame",
                    user_score: 9000,
                    user_avatar: UserAvatar(
                        b: "d55161",
                        i: "v-37_c-3_b-2_g-m_9-1_1-6_16-4_3-6_8-4_7-4_5-4_12-6_17-2_6-15_2-26_22-7_15-3_11-3_18-4_19-4_4-4_20-1_21-1.jpg"
                        //i: nil
                    ),
                    user_dpp: nil,
                    attached_image: AttachedImage(
                        url: "https://avatars.devrant.com/v-37_c-1_b-5_g-m_9-1_1-1_16-7_3-2_8-2_7-2_5-1_12-1_6-97_10-9_2-90_22-7_11-8_18-3_19-2_4-1_20-2.png",
                        width: 1400,
                        height: 1400)
                ))
    }
}
