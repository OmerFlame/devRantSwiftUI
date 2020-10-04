//
//  AvatarEditor.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI

struct MainScreen: View {
    @State var apiRequest: APIRequest
    
    @State var shouldShowSettings = false
    @State var shouldShowLogin = false
    @State var shouldShowLoadingRing = true
    
    @State var shouldShowError = false
    
    @State var rantFeed: RantFeed?
    
    @State var isSheet = true
    
    private func getFeed() {
        do {
            self.rantFeed = try self.apiRequest.getRantFeed()
            
            print("IS RANT FEED EMPTY: \(self.rantFeed == nil)")
        } catch {
            DispatchQueue.main.async {
                self.shouldShowError.toggle()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            if self.rantFeed == nil || self.shouldShowLoadingRing == true {
                VStack(alignment: .center) {
                    ProgressView("Loading Rants")
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            if self.rantFeed == nil {
                                self.shouldShowLoadingRing = true
                                DispatchQueue.global(qos: .userInitiated).async {
                                    self.getFeed()
                                    
                                    DispatchQueue.main.async {
                                        print("IS RANT FEED EMPTY: \(self.rantFeed == nil)")
                                        self.shouldShowLoadingRing.toggle()
                                    }
                                }
                            }
                    }
                }
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
                            /*RantView(rant: RantModel(id: 327111,
                                                         text: "My girlfriend got me this mug. She's the one.",
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
                                                                    )),
                                                            CommentModel(id: 327120,
                                                                    rant_id: 327111,
                                                                    body: "Wow its picture where torvalds show fuck off to nvidia coolSKDHFGJSKDLFJHGLSKDFJHGL",
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
                            )*/
                            ForEach(self.rantFeed!.rants, id: \.uuid) { rant in
                                RantInFeedView(rantContents: rant)
                                    //.fixedSize(horizontal: false, vertical: true)
                                    .frame(alignment: .leading)
                            }
                            
                            NavigationLink(
                                destination: ProfileView(),
                                label: {
                                    Text("Navigate")
                                })
                        }.navigationBarTitle(Text("devRant"))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Menu(content: {
                                    Button(action: {
                                        self.shouldShowSettings.toggle()
                                    }, label: {
                                        HStack {
                                            Text("Settings")
                                            Image(systemName: "gearshape.fill")
                                        }
                                    })
                                       
                                    Button(action: {
                                        self.shouldShowLogin.toggle()
                                    }, label: {
                                        HStack {
                                            Text("Log Out")
                                            Image(systemName: "lock.fill")
                                        }
                                    })
                                }, label: { Image(systemName: "ellipsis.circle.fill").font(.system(size: 25)) }
                                )
                            }
                        }
                        .sheet(isPresented: $shouldShowLogin, content: {
                            LoginScreen(showVar: $shouldShowLogin, apiRequest: self.apiRequest).presentation(isSheet: $isSheet)
                        })
                        .padding(.top)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension UIScrollView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.isDirectionalLockEnabled = true
        
        if scrollView.contentOffset.x > 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(apiRequest: APIRequest(userIDUserDefaultsIdentifier: "UserID", tokenIDUserDefaultsIdentifier: "TokenID", tokenKeyUserDefaultsIdentifier: "TokenKey"))
    }
}
