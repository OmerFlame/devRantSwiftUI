//
//  FancyScrollView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/18/20.
//

import SwiftUI

public struct FancyScrollView: View {
    let title: String
    let upvotes: Int
    @Binding var pageSelection: ProfilePages
    var opacity: Double
    let headerHeight: CGFloat
    let scrollUpHeaderBehavior: ScrollUpHeaderBehavior
    let scrollDownHeaderBehavior: ScrollDownHeaderBehavior
    let header: Header?
    let content: AnyView

    public var body: some View {
        if let header = header {
            return AnyView(
                HeaderScrollView(title: title,
                                 upvotes: self.upvotes,
                                 pageSelection: self.$pageSelection,
                                 opacity: opacity,
                                 headerHeight: headerHeight,
                                 scrollUpBehavior: scrollUpHeaderBehavior,
                                 scrollDownBehavior: scrollDownHeaderBehavior,
                                 header: header,
                                 content: content)
            )
        } else {
            return AnyView(
                AppleMusicStyleScrollView {
                    VStack {
                        title != "" ? HStack {
                            Text(title)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .fontWeight(.black)
                                .padding(.horizontal, 16)

                            Spacer()
                        } : nil

                        title != "" ? Spacer() : nil

                        content
                    }
                }
            )
        }
    }
}

extension FancyScrollView {

    public init<B: View>(title: String = "",
                                  upvotes: Int,
                                  choice: Binding<ProfilePages>,
                                  opacity: Double,
                                  headerHeight: CGFloat = 300,
                                  scrollUpHeaderBehavior: ScrollUpHeaderBehavior = .parallax,
                                  scrollDownHeaderBehavior: ScrollDownHeaderBehavior = .offset,
                                  header: Header?,
                                  content: () -> B) {

        self.init(title: title,
                  upvotes: upvotes,
                  pageSelection: choice,
                  opacity: opacity,
                  headerHeight: headerHeight,
                  scrollUpHeaderBehavior: scrollUpHeaderBehavior,
                  scrollDownHeaderBehavior: scrollDownHeaderBehavior,
                  header: header,
                  content: AnyView(content()))
    }

    public init<A: View>(title: String = "",
                         headerHeight: CGFloat = 300,
                         upvotes: Int,
                         choice: Binding<ProfilePages>,
                         opacity: Double,
                         scrollUpHeaderBehavior: ScrollUpHeaderBehavior = .parallax,
                         scrollDownHeaderBehavior: ScrollDownHeaderBehavior = .offset,
                         content: () -> A) {

           self.init(title: title,
                     upvotes: upvotes,
                     pageSelection: choice,
                     opacity: opacity,
                     headerHeight: headerHeight,
                     scrollUpHeaderBehavior: scrollUpHeaderBehavior,
                     scrollDownHeaderBehavior: scrollDownHeaderBehavior,
                     header: nil,
                     content: AnyView(content()))
       }

}
