//
//  HeaderScrollView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/18/20.
//

import SwiftUI

private let navigationBarHeight: CGFloat = 44

struct HeaderScrollView: View {
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    let title: String
    let upvotes: Int
    @Binding var pageSelection: ProfilePages
    var opacity: Double
    @State var selectedPage: ProfilePages = .rants
    let headerHeight: CGFloat
    let scrollUpBehavior: ScrollUpHeaderBehavior
    let scrollDownBehavior: ScrollDownHeaderBehavior
    let header: Header
    let content: AnyView
    
    func scrollToTop(_ reader: ScrollViewProxy) {
        withAnimation {
            reader.scrollTo("Header", anchor: .top)
        }
    }

    var body: some View {
        
        
        GeometryReader { globalGeometry in
            ScrollView {
                ScrollViewReader { reader in
                    VStack(spacing: 0) {
                        GeometryReader { geometry -> AnyView in
                            let geometry = self.geometry(from: geometry, safeArea: globalGeometry.safeAreaInsets)
                            //self.header.imageOpacity = geometry.largeTitleWeight
                            return AnyView(Header(imageOpacity: geometry.largeTitleWeight, image: self.header.image, userAvatar: self.header.userAvatar)
                                            
                                            .id("Header")
                                            .frame(width: geometry.width, height: geometry.headerHeight)
                                            .clipped()
                                            //.opacity(sqrt(geometry.largeTitleWeight))
                                            //.opacity(0.5)
                                            .offset(y: geometry.headerOffset))
                        }
                        .frame(width: globalGeometry.size.width, height: self.headerHeight)

                        GeometryReader { geometry -> AnyView in
                            let geometry = self.geometry(from: geometry, safeArea: globalGeometry.safeAreaInsets)
                            return AnyView(
                                ZStack {
                                    BlurView()
                                        .opacity(1 - sqrt(geometry.largeTitleWeight))
                                        .offset(y: geometry.blurOffset)

                                    VStack(spacing: 0) {
                                        geometry.largeTitleWeight == 1 ? HStack {
                                            BackButton(color: .white)
                                            Spacer()
                                        }.frame(width: geometry.width, height: navigationBarHeight) : nil

                                        Spacer()

                                        HeaderScrollViewTitle(title: self.title,
                                                              upvotes: self.upvotes,
                                                              pageSelection: self.$pageSelection,
                                                              height: navigationBarHeight,
                                                              largeTitle: geometry.largeTitleWeight).layoutPriority(1000)
                                            //.padding(.top, 105)
                                        
                                        Picker("", selection: $selectedPage) {
                                            ForEach(ProfilePages.allCases, id: \.self) { selection in
                                                Text(selection.rawValue).tag(selection)
                                            }
                                        }
                                        .onChange(of: selectedPage) { newValue in
                                            scrollToTop(reader)
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                self.pageSelection = newValue
                                            }
                                            //self.pageSelection = newValue
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                        .padding([.leading, .trailing])
                                        .layoutPriority(1000)
                                        .padding(.bottom, 8)
                                    }
                                    .padding(.top, globalGeometry.safeAreaInsets.top)
                                    .frame(width: geometry.width, height: max(geometry.elementsHeight, navigationBarHeight))
                                    .offset(y: geometry.elementsOffset)
                                }
                            )
                        }
                        .frame(width: globalGeometry.size.width, height: self.headerHeight + 38)
                        .zIndex(1000)
                        .offset(y: -(self.headerHeight))

                        self.content
                            .background(Color.background(colorScheme: self.colorScheme))
                            .offset(y: -self.headerHeight)
                            .padding(.bottom, -self.headerHeight)
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarHidden(true)
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

extension HeaderScrollView {

    private struct HeaderScrollViewGeometry {
        let width: CGFloat
        let headerHeight: CGFloat
        let elementsHeight: CGFloat
        let headerOffset: CGFloat
        let blurOffset: CGFloat
        let elementsOffset: CGFloat
        let largeTitleWeight: Double
    }

    private func geometry(from geometry: GeometryProxy, safeArea: EdgeInsets) -> HeaderScrollViewGeometry {
        let minY = geometry.frame(in: .global).minY
        let hasScrolledUp = minY > 0
        let hasScrolledToMinHeight = -minY >= headerHeight - navigationBarHeight - safeArea.top

        let headerHeight = hasScrolledUp && self.scrollUpBehavior == .parallax ?
            geometry.size.height + minY + 38 : geometry.size.height + 38

        let elementsHeight = hasScrolledUp && self.scrollUpBehavior == .sticky ?
            geometry.size.height : geometry.size.height + minY

        let headerOffset: CGFloat
        let blurOffset: CGFloat
        let elementsOffset: CGFloat
        let largeTitleWeight: Double

        if hasScrolledUp {
            headerOffset = -minY
            blurOffset = -minY
            elementsOffset = -minY
            largeTitleWeight = 1
        } else if hasScrolledToMinHeight {
            headerOffset = -minY - self.headerHeight + navigationBarHeight + safeArea.top
            blurOffset = -minY - self.headerHeight + navigationBarHeight + safeArea.top
            elementsOffset = headerOffset / 2 - minY / 2
            largeTitleWeight = 0
        } else {
            headerOffset = self.scrollDownBehavior == .sticky ? -minY : 0
            blurOffset = 0
            elementsOffset = -minY / 2
            let difference = self.headerHeight - navigationBarHeight - safeArea.top + minY
            largeTitleWeight = difference <= navigationBarHeight + 1 ? Double(difference / (navigationBarHeight + 1)) : 1
        }

        return HeaderScrollViewGeometry(width: geometry.size.width,
                                        headerHeight: headerHeight,
                                        elementsHeight: elementsHeight,
                                        headerOffset: headerOffset,
                                        blurOffset: blurOffset,
                                        elementsOffset: elementsOffset,
                                        largeTitleWeight: largeTitleWeight)
    }

}

extension Color {

    static func background(colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return .black
        case .light:
            fallthrough
        @unknown default:
            return .white
        }
    }

}
