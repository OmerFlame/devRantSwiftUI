//
//  SecondaryDetailedRantView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/25/20.
//

import SwiftUI
import BottomBar_SwiftUI

public enum ProfilePages: String, CaseIterable {
    case rants = "Rants"
    case upvotes = "++'s"
    case comments = "Comments"
    case favorites = "Favorites"
}

struct ProfileView: View {
    @State var viewSelection: ProfilePages = .rants
    @State var isComplete = false
    @State var shouldShowError = false
    
    let userID: Int
    @State var userInfo: Profile? = nil
    
    @State var image: UIImage?
    @State var imageOpacity: Double = 1
    
    init(userID: Int) {
        UISegmentedControl.appearance().backgroundColor = .systemBackground
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        self.userID = userID
        
        do {
            //self._userInfo = State(initialValue: nil)
            self._image = State(initialValue: UIImage())
            
        } catch let error {
            print(error.localizedDescription)
            self.userInfo = nil
        }
    }
    
    func getImage() {
        let completionSemaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: URL(string: "https://avatars.devrant.com/\(self.userInfo!.avatar.i!)")!) { data, _, _ in
            self.image = UIImage(data: data!)
            
            completionSemaphore.signal()
        }.resume()
        
        completionSemaphore.wait()
        return
    }
    
    func getUserInfo() {
        do {
            self.userInfo = try APIRequest().getProfileFromID(self.userID, userContentType: .rants, skip: 0)!.profile
            UISegmentedControl.appearance().backgroundColor = .systemBackground
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(hex: self.userInfo!.avatar.b)
        } catch let error {
            print(error.localizedDescription)
            self.userInfo = nil
        }
    }
    
    var body: some View {
        if self.isComplete == false {
            VStack(alignment: .center) {
                ProgressView("Loading Profile")
                    .progressViewStyle(CircularProgressViewStyle())
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            DispatchQueue.global(qos: .userInitiated).sync {
                                self.getUserInfo()
                                
                                if self.userInfo?.avatar.i != nil {
                                    self.getImage()
                                }
                                
                                DispatchQueue.main.async {
                                    self.isComplete = true
                                }
                            }
                        }
                    }
            }
        } else if self.isComplete && self.userInfo == nil {
            EmptyView()
                .onAppear {
                    self.shouldShowError.toggle()
                }
        } else {
            ZStack(alignment: .bottom) {
                if self.userInfo?.avatar.i != nil {
                    let imageHeader = Header(imageOpacity: 1.0, image: self.image!, userAvatar: self.userInfo!.avatar)
                    FancyScrollView(title: self.userInfo!.username,
                                    upvotes: self.userInfo!.score,
                                    choice: $viewSelection,
                                    opacity: imageHeader.imageOpacity,
                                    headerHeight: 450,
                                    scrollUpHeaderBehavior: .parallax,
                                    scrollDownHeaderBehavior: .offset,
                                    header: imageHeader /*{
                                        /*ZStack(alignment: .trailing) {
                                            Image(uiImage: self.image!).resizable().aspectRatio(contentMode: .fill)
                                        }*/
                                        
                                        //Image(uiImage: self.image!).resizable().aspectRatio(contentMode: .fill)
                                        GeometryReader { geometry in
                                            ZStack {
                                                Rectangle()
                                                    .fill(Color(UIColor(hex: self.userInfo!.avatar.b)!))
                                                    .aspectRatio(contentMode: .fill)
                                                    .fixedSize(horizontal: false, vertical: false)
                                                    .opacity(sqrt(self.imageOpacity))
                                                Image(uiImage: self.image!).resizable().aspectRatio(contentMode: .fill)
                                                    .frame(width: geometry.size.width - 100, height: geometry.size.height - 100, alignment: .center)
                                                    .opacity(self.imageOpacity)
                                            }
                                            .aspectRatio(contentMode: .fill)
                                            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                                            .opacity(sqrt(self.imageOpacity))
                                            //.fixedSize(horizontal: false, vertical: false)
                                        }
                                        .opacity(sqrt(self.imageOpacity))
                                    }*/) {
                        self.builder()
                    }
                } else {
                    ScrollView {
                        VStack {
                            Text("Placeholder")
                        }.navigationTitle("Test")
                    }
                }
                    
                //.navigationBarHidden(true)
                //.edgesIgnoringSafeArea([.top, .bottom])
                
                Spacer()
                
                /*Picker("Categories", selection: $viewSelection) {
                    ForEach(ProfilePages.allCases, id: \.self) { selection in
                        Text(selection.rawValue).tag(selection)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.leading, .trailing])
                .edgesIgnoringSafeArea(.bottom)*/
            }
        }
    }
    
    func builder() -> AnyView {
        if self.viewSelection == .rants {
            return withAnimation { AnyView(RantsList(userID: self.userID)) }
        } else if self.viewSelection == .upvotes {
            return withAnimation { AnyView(Text("++'s")) }
        } else if self.viewSelection == .comments {
            return withAnimation { AnyView(Text("Comments")) }
        } else if self.viewSelection == .favorites {
            return withAnimation { AnyView(Text("Favorites")) }
        }
        
        return AnyView(RantsList(userID: self.userID))
    }
}

public struct Header: View {
    var imageOpacity: Double
    let image: UIImage
    let userAvatar: UserAvatar
    
    public var body: some View {
        GeometryReader { geometry in
            Color(UIColor(hex: self.userAvatar.b)!)
                //.opacity(0.5)
                .overlay(
                    Image(uiImage: self.image).resizable().aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width - 100, height: geometry.size.height - 100, alignment: .center)
                )
                //.background(Color(UIColor(hex: self.userAvatar.b)!).opacity(0.5))
                .aspectRatio(contentMode: .fill)
                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                .overlay(Rectangle().fill(Color.black).frame(width: geometry.size.width, height: geometry.size.height).opacity(sqrt(1 - self.imageOpacity)))
            //.opacity(sqrt(self.imageOpacity))
            //.opacity(sqrt(0.5))
            //.fixedSize(horizontal: false, vertical: false)
        }
        //.background(Color(UIColor(hex: self.userAvatar.b)!))
        //.background(Color(hue: 154, saturation: 25.8, brightness: 51.4))
        //.opacity(sqrt(self.imageOpacity))
        //.opacity(0.5)
    }
}

struct RantsList: View {
    let userID: Int
    @State var data: [RantInFeed]?
    
    @State var shouldShowError = false
    @State var shouldShowRing = true
    
    init(userID: Int) {
        self.userID = userID
        
        self._data = State(initialValue: [])
    }
    
    func getRants() {
        do {
            self.data = try APIRequest().getProfileFromID(self.userID, userContentType: .rants, skip: 0)?.profile.content.content.rants
        } catch let error {
            print(error.localizedDescription)
            self.data = nil
        }
    }
    
    var body: some View {
        if self.shouldShowRing {
            VStack(alignment: .center) {
                ProgressView("Loading Rants")
                    .padding(.top)
                    .progressViewStyle(CircularProgressViewStyle())
                    .onAppear {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.getRants()
                            
                            DispatchQueue.main.async {
                                self.shouldShowRing = false
                            }
                        }
                    }
            }
        } else if !self.shouldShowRing && self.data == nil {
            EmptyView()
                .onAppear {
                    self.shouldShowError.toggle()
                }
        } else {
            VStack {
                ForEach(data!, id: \.uuid) { rant in
                    RantInFeedView(rantContents: rant)
                }
            }
            .padding(.bottom, 25)
            .padding(.top)
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
        ProfileView(userID: 1392945)
    }
}
