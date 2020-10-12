//
//  SecondaryDetailedRantView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/25/20.
//

import SwiftUI
import FancyScrollView
import BottomBar_SwiftUI

struct ProfileView: View {
    @State var viewSelection: TestEnum = .test1
    
    init() {
        UISegmentedControl.appearance().backgroundColor = .systemBackground
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(hex: "d55161")
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            /*ScrollViewParallaxRepresentable(image: UIImage(named: "background_image")!) {
                RantView(rant: RantModel(id: 327111,
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
                                                    body: "Wow its picture where torvalds show fuck off to nvidia coolaskdljfhaklsdjhflaksjhdflkajshdfkljahsdflkjhasdf",
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
                                                    body: "Wow its picture where torvalds show fuck off to nvidia cool",
                                                    score: 8,
                                                    created_time: 1481230451,
                                                    vote_state: 0,
                                                    user_id: 19218,
                                                    user_username: "Haxk20",
                                                    user_avatar: UserAvatar(
                                                        b: "7bc8a4",
                                                        i: "v-37_c-3_b-1_g-m_9-2_1-2_16-14_3-3_8-3_7-3_5-4_12-2_6-3_10-1_2-109_22-1_18-4_19-5_4-4_20-15_21-4.jpg"
                                                    ))
                                    ]))
                
                
            }*/
            
            FancyScrollView(title: "OmerFlame",
                            headerHeight: 450,
                            scrollUpHeaderBehavior: .parallax,
                            scrollDownHeaderBehavior: .offset,
                            header: { Image("background_image").resizable().aspectRatio(contentMode: .fill) }) {
                
                Text("Placeholder")
            }
                
            //.navigationBarHidden(true)
            //.edgesIgnoringSafeArea([.top, .bottom])
            
            Spacer()
            
            Picker("Categories", selection: $viewSelection) {
                ForEach(TestEnum.allCases, id: \.self) { selection in
                    Text(selection.rawValue).tag(selection)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing, .bottom])
        }
    }
}

struct PreventCollapseView: View {
    var body: some View {
        Rectangle()
            .fill(Color(UIColor.systemBackground))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 1)
    }
}

struct ProfileRantsView: View {
    @State var rants: [RantInFeed]
    
    var body: some View {
        List {
            ForEach(self.rants, id: \.uuid) { rant in
                RantInFeedView(rantContents: rant)
            }
        }
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
