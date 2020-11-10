//
//  RantInFeedView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/1/20.
//

import SwiftUI

struct RantInFeedView: View {
    @State private var totalHeight = CGFloat.zero
    @State var shouldShowError = false
    @Binding var rantContents: RantInFeed
    var parentTableView: UITableView
    let uiImage: UIImage?
    
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
        NavigationLink(destination: RantView(rantID: self.rantContents.id, apiRequest: APIRequest(), rantInFeed: $rantContents)) {
            HStack {
                VStack {
                    HStack(alignment: .top) { // START MAIN HSTACK
                        VStack(spacing: 1) { // UPVOTE / DOWNVOTE VSTACK
                            Button(action: {
                                var vote: Int {
                                    switch self.rantContents.vote_state {
                                    case 0:
                                        return 1
                                        
                                    case 1:
                                        return 0
                                        
                                    default:
                                        return 1
                                    }
                                }
                                
                                let success = APIRequest().voteOnRant(rantID: self.rantContents.id, vote: vote)
                                
                                if !success {
                                    self.shouldShowError.toggle()
                                } else {
                                    self.rantContents.vote_state = vote
                                    
                                    parentTableView.reloadData()
                                }
                            }, label: {
                                if self.rantContents.vote_state == 1 {
                                    //Image(systemName: "plus.circle.fill").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                    Image("plusplus").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                    /*Image(uiImage: UIImage(named: "upvote")!)
                                        .font(.system(size: 25))
                                        .accentColor(Color(UIColor(hex: rantContents.user_avatar.b)!))*/
                                        
                                } else if self.rantContents.vote_state == 0 {
                                    Image("plusplus").accentColor(.gray).font(.system(size: 25))
                                } else {
                                    Image("plusplus").accentColor(.gray).font(.system(size: 25))
                                }
                            })
                            Text(String(self.rantContents.score)).font(.subheadline)
                            Button(action: {
                                var vote: Int {
                                    switch self.rantContents.vote_state {
                                    case 0:
                                        return -1
                                        
                                    case -1:
                                        return 0
                                        
                                    default:
                                        return -1
                                    }
                                }
                                
                                let success = APIRequest().voteOnRant(rantID: self.rantContents.id, vote: vote)
                                
                                if !success {
                                    self.shouldShowError.toggle()
                                } else {
                                    self.rantContents.vote_state = vote
                                    parentTableView.reloadData()
                                }
                            }, label: {
                                if self.rantContents.vote_state == -1 {
                                    Image("minusminus").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                } else if self.rantContents.vote_state == 0 {
                                    Image("minusminus").accentColor(.gray).font(.system(size: 25))
                                } else {
                                    Image("minusminus").accentColor(.gray).font(.system(size: 25))
                                }
                            })
                        }.disabled(self.rantContents.vote_state == -2) // END UPVOTE / DOWNVOTE VSTACK
                        
                        // MAXIMUM 240 CHARS
                        
                        VStack {
                            HStack {
                                if self.rantContents.text.count >= 240 {
                                    Text(self.rantContents.text.prefix(240) + "... [read more]")
                                        .padding(.trailing)
                                        .fixedSize(horizontal: false, vertical: true)
                                } else {
                                    Text(self.rantContents.text)
                                        .padding(.trailing)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer()
                            }
                            
                            VStack {
                                if self.uiImage != nil && self.rantContents.attached_image != nil {
                                    //let url = File.loadFiles(images: [self.rantContents.attached_image!])[0].url
                                    let resizeMultiplier = self.getImageResizeMultiplier(
                                        imageWidth: CGFloat(self.rantContents.attached_image!.width!),
                                        imageHeight: CGFloat(self.rantContents.attached_image!.height!), multiplier: 1)
                                    
                                    let finalWidth = CGFloat(self.rantContents.attached_image!.width!) / resizeMultiplier
                                    let finalHeight = CGFloat(self.rantContents.attached_image!.height!) / resizeMultiplier
                                    
                                    HStack {
                                        //ImageView(withURL: "https://img.devrant.com/\(self.rantContents.attached_image!.url)", width: finalWidth, height: finalHeight)
                                        Image(uiImage: self.uiImage!)
                                            .resizable()
                                            .foregroundColor(Color(UIColor.systemBackground))
                                            //.fixedSize(horizontal: false, vertical: true)
                                            .scaledToFit()
                                            .frame(width: finalWidth,
                                                   height: finalHeight)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                        
                                        Spacer()
                                    }
                                }
                                
                                TagCloudView(tags: self.rantContents.tags, color: Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                            }
                        }
                    }.padding([.top, .leading, .bottom])
                    
                    //Divider()
                }
            } // END MAIN HSTACK
        }.buttonStyle(PlainButtonStyle())
        .frame(minHeight: 0, maxHeight: .infinity)
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}
