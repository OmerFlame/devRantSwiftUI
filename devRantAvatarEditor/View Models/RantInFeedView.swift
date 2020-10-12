//
//  RantInFeedView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/1/20.
//

import SwiftUI
import FancyScrollView

enum TestEnum: String, CaseIterable {
    case test1 = "Test 1"
    case test2 = "Test 2"
    case test3 = "Test 3"
    case test4 = "Test 4"
}

struct RantInFeedView: View {
    @State private var totalHeight = CGFloat.zero
    
    @State var rantContents: RantInFeed
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
    
    func item(for text: String) -> some View {
        Text(text)
            .padding(.all, 5)
            .font(.footnote)
            .background(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
            .foregroundColor(Color.white)
            .cornerRadius(5)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.rantContents.tags, id: \.self) { item in
                self.item(for: item)
                    .padding([.horizontal, .vertical], 2)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == self.rantContents.tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if item == self.rantContents.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
                }
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                HStack(alignment: .top) { // START MAIN HSTACK
                    VStack { // UPVOTE / DOWNVOTE VSTACK
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
                    } // END UPVOTE / DOWNVOTE VSTACK
                    
                    
                    VStack {
                        HStack {
                            Text(self.rantContents.text)
                                .padding(.trailing)
                            
                            Spacer()
                        }
                        
                        VStack {
                            TagCloudView(tags: self.rantContents.tags, color: Color.blue)
                        }
                    }
                }.padding([.top, .leading])
                
                Divider()
            }
        } // END MAIN HSTACK
    }
}

struct RantInFeedView_Previews: PreviewProvider {
    static var previews: some View {
        RantInFeedView(rantContents: RantInFeed(id: 327111,
                                                text: "My girlfriend got me this mug. She is the one.",
                                                score: 157,
                                                created_time: 1481230115,
                                                attached_image: .attachedImage(AttachedImage(
                                                    url: "https://img.devrant.com/devrant/rant/r_327111_pMWmu.jpg",
                                                    width: 562,
                                                    height: 1000
                                                 )),
                                                num_comments: 1,
                                                tags: ["undefined", "linusgh", "torvalds", "mug"],
                                                vote_state: 0,
                                                edited: false,
                                                link: "rants/327111/my-girlfriend-got-me-this-mug-shes-the-one",
                                                rt: 1,
                                                rc: 7,
                                                c_type: nil,
                                                c_type_long: nil,
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
                                                user_dpp: 0))
    }
}
