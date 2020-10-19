//
//  HeaderScrollViewTitle.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/18/20.
//

import SwiftUI

struct HeaderScrollViewTitle: View {
    let title: String
    let upvotes: Int
    @Binding var pageSelection: ProfilePages
    let height: CGFloat
    let largeTitle: Double

    var body: some View {
        let largeTitleOpacity = (max(largeTitle, 0.5) - 0.5) * 2
        let tinyTitleOpacity = 1 - min(largeTitle, 0.5) * 2
        return ZStack {
            HStack(alignment: .center) {
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .fontWeight(.black)
                    .padding(.leading, 16)
                    .fixedSize(horizontal: true, vertical: false)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color.white)
                    Text("+" + String(self.upvotes)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.black)
                }.fixedSize().frame(alignment: .center).padding(.top, 5)
                
                Spacer()
                //.padding(.vertical, 16)
            }.padding(.bottom, 8)
            .opacity(sqrt(largeTitleOpacity))

            ZStack {
                HStack {
                    BackButton(color: .primary)
                    Spacer()
                }
                
                HStack {
                    Text(title)
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color.white)
                        Text("+" + String(self.upvotes)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.black)
                    }.fixedSize()
                }
            }
            .padding(.bottom, (height - 18) / 2)
            .opacity(sqrt(tinyTitleOpacity))
        }.frame(height: height)
    }
}

