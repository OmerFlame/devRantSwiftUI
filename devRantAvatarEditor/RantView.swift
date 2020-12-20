//
//  RantView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/14/20.
//

import SwiftUI

struct RantView: View {
    let rantID: Int
    @State var apiRequest: APIRequest
    
    @State var rant: RantResponse? = nil
    @Binding var rantInFeed: RantInFeed
    @State var shouldShowRing = true
    @State var shouldShowError = false
    
    @State var shouldShowCompose = false
    
    @State var ranterImage: UIImage? = nil
    @State var profile: Profile? = nil
    
    private func getRant() {
        do {
            self.rant = try self.apiRequest.getRantFromID(id: self.rantID)
            
            print("IS RANT EMPTY: \(self.rant == nil)")
        } catch {
            DispatchQueue.main.async {
                self.shouldShowError.toggle()
            }
        }
    }
    
    private func getRanterImage() {
        let completionSemaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: URL(string: "https://avatars.devrant.com/\(self.rant!.rant.user_avatar_lg.i!)")!) { data, _, _ in
            self.ranterImage = UIImage(data: data!)
            
            completionSemaphore.signal()
        }.resume()
        
        completionSemaphore.wait()
        return
    }
    
    private func getProfile() {
        do {
            self.profile = try self.apiRequest.getProfileFromID(rant!.rant.user_id, userContentType: .rants, skip: 0)?.profile
        } catch {
            DispatchQueue.main.async {
                self.shouldShowError.toggle()
            }
        }
    }
    
    var body: some View {
        if self.rant == nil || self.shouldShowRing == true {
            VStack(alignment: .center) {
                ProgressView("Loading Rant")
                    .progressViewStyle(CircularProgressViewStyle())
                    .onAppear {
                        if self.rant == nil {
                            self.shouldShowRing = true
                            /*DispatchQueue.global(qos: .userInitiated).async {
                                self.getRant()
                                
                                DispatchQueue.main.async {
                                    print("IS RANT FEED EMPTY: \(self.rant == nil)")
                                    self.shouldShowRing.toggle()
                                }
                            }*/
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                DispatchQueue.global(qos: .userInitiated).sync {
                                    self.getRant()
                                    self.getProfile()
                                    
                                    if self.rant?.rant.user_avatar_lg.i != nil {
                                        self.getRanterImage()
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.shouldShowRing = false
                                    }
                                }
                            }
                        }
                }
            }
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    Rant(rantContents: (self.rant?.rant)!, rantInFeed: $rantInFeed, userImage: self.ranterImage, profile: self.profile!)
                        .padding([.trailing])
                        //.fixedSize(horizontal: false, vertical: true)
                
                    ForEach((self.rant?.comments)!) { comment in
                        Comment(highlightColor: Color(UIColor(hex: comment.user_avatar.b)!), commentContents: comment)
                            .frame(alignment: .topLeading)
                            .padding([.trailing])
                    }
                }
                //.padding(.leading)
            }
            .navigationBarTitle("Rant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.shouldShowCompose.toggle()
                    }, label: {
                        Image(systemName: "square.and.pencil")
                    })
                }
            }
            .onAppear {
                print("View appeared!")
            }
            .sheet(isPresented: $shouldShowCompose) {
                ComposeView(shouldShow: $shouldShowCompose, isComment: true, rantID: self.rantID).presentation(isSheet: .constant(true))
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
