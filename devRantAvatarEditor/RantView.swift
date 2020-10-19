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
    @State var shouldShowRing = true
    @State var shouldShowError = false
    
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
    
    var body: some View {
        if self.rant == nil || self.shouldShowRing == true {
            VStack(alignment: .center) {
                ProgressView("Loading Rant")
                    .progressViewStyle(CircularProgressViewStyle())
                    .onAppear {
                        if self.rant == nil {
                            self.shouldShowRing = true
                            DispatchQueue.global(qos: .userInitiated).async {
                                self.getRant()
                                
                                DispatchQueue.main.async {
                                    print("IS RANT FEED EMPTY: \(self.rant == nil)")
                                    self.shouldShowRing.toggle()
                                }
                            }
                        }
                }
            }
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    Rant(rantContents: (self.rant?.rant)!)
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
            .onAppear {
                print("View appeared!")
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

struct RantView_Previews: PreviewProvider {
    static var previews: some View {
        RantView(rantID: 3240155, apiRequest: APIRequest())
    }
}
