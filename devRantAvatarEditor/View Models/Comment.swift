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
