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
                            ForEach(self.rantFeed!.rants, id: \.uuid) { rant in
                                NavigationLink(
                                    destination: RantView(rantID: rant.id, apiRequest: self.apiRequest)) {
                                        RantInFeedView(rantContents: rant)
                                            //.fixedSize(horizontal: false, vertical: true)
                                            .frame(alignment: .leading)
                                            
                                }
                                .buttonStyle(PlainButtonStyle())
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
