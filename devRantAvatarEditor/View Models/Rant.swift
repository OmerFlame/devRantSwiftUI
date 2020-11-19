//
//  Rant.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI
import QuickLook
import Combine

struct Rant: View {
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    @State var shouldShowLoadingRing = true
    @State var rantContents: RantModel
    @Binding var rantInFeed: RantInFeed
    let userImage: UIImage?
    let profile: Profile
    
    var file: File?
    @State var shouldShowError = false
    
    @State var shouldPreview = false
    
    @State var url: URL?
    
    @State private var thumbnailRect: CGRect = .zero
    
    init(rantContents: RantModel, rantInFeed: Binding<RantInFeed>, userImage: UIImage?, profile: Profile) {
        self._rantContents = State(initialValue: rantContents)
        self._rantInFeed = rantInFeed
        self.userImage = userImage
        self.profile = profile
        self.file = nil
        
        if rantContents.attached_image != nil {
            let resizeMultiplier = self.getImageResizeMultiplier(imageWidth: CGFloat(rantContents.attached_image!.width!), imageHeight: CGFloat(rantContents.attached_image!.height!), multiplier: 1)
            
            let finalWidth = CGFloat(rantContents.attached_image!.width!) / resizeMultiplier
            let finalHeight = CGFloat(rantContents.attached_image!.height!) / resizeMultiplier
            
            self.file = Optional(File.loadFile(image: rantContents.attached_image!, size: CGSize(width: finalWidth, height: finalHeight)))
            
            //print("THE FINAL URL: \(url)")
            
            //self._url = State(initialValue: Optional(File.loadFiles(images: [rantContents.attached_image!])[0].url))
        } else {
            self._url = State(initialValue: URL(string: ""))
            self.file = nil
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                HStack(alignment: .top) {
                    VStack(spacing: 1) {
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
                            }
                            
                            self.rantInFeed.vote_state = self.rantContents.vote_state
                        }, label: {
                            if self.rantContents.vote_state == 1 {
                                //Image(systemName: "plus.circle.fill").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                Image("plusplus").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                            } else if self.rantContents.vote_state == 0 {
                                Image("plusplus").font(.system(size: 25)).accentColor(.gray)
                            } else {
                                Image("plusplus").font(.system(size: 25)).disabled(true).font(.system(size: 25))
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
                            }
                            
                            self.rantInFeed.vote_state = self.rantContents.vote_state
                        }, label: {
                            if self.rantContents.vote_state == -1 {
                                Image("minusminus").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                            } else if self.rantContents.vote_state == 0 {
                                Image("minusminus").accentColor(.gray).font(.system(size: 25))
                            } else {
                                Image("minusminus").disabled(true).font(.system(size: 25))
                            }
                        })
                    }
                    
                    
                    //.scaledToFill()
                    
                    VStack {
                        /*HStack {
                            if self.rantContents.user_avatar.i == nil {
                                let color = UIColor(hex: self.rantContents.user_avatar.b)
                                
                                Circle()
                                    .size(CGSize(width: 45, height: 45))
                                    .fill(Color(color!))
                                    .frame(width: 45, height: 45)
                                    //.padding(.trailing)
                                
                                VStack(alignment: .leading, spacing: 1.0) {
                                    Text(self.rantContents.user_username)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .scaledToFill()
                                    
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 5).fill(Color(color!))
                                        Text("+" + String(self.rantContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                    }.fixedSize()
                                }.scaledToFit()
                                
                                Spacer()
                            } else {
                                ImageView(withURL: "https://avatars.devrant.com/" + self.rantContents.user_avatar.i!, width: 45, height: 45)
                                        .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 1.0) {
                                    Text(self.rantContents.user_username).fixedSize(horizontal: false, vertical: true).scaledToFill()
                                        
                                    ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 5).fill(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                        Text("+" + String(self.rantContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                    }.fixedSize()
                                }.scaledToFit()
                                
                                
                                Spacer()
                            }
                        }*/
                        
                        NavigationLink(
                            destination: /*ProfileInfiniteScrollViewRepresentable(userID: self.rantContents.user_id).edgesIgnoringSafeArea(.top)*/ //SecondaryProfileRepresentable(userID: self.rantContents.user_id)
                                TertiaryProfileScrollSwiftUI(userID: self.rantContents.user_id, profileData: .constant(self.profile), image: .constant(self.userImage))
                                .edgesIgnoringSafeArea(.top)
                                .navigationBarHidden(true),
                            label: {
                                HStack {
                                    if self.rantContents.user_avatar.i == nil {
                                        let color = UIColor(hex: self.rantContents.user_avatar.b)
                                        
                                        Circle()
                                            .size(CGSize(width: 45, height: 45))
                                            .fill(Color(color!))
                                            .frame(width: 45, height: 45)
                                            //.padding(.trailing)
                                        
                                        VStack(alignment: .leading, spacing: 1.0) {
                                            Text(self.rantContents.user_username)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .scaledToFill()
                                            
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 5).fill(Color(color!))
                                                Text("+" + String(self.rantContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                            }.fixedSize()
                                        }.scaledToFit()
                                        
                                        Spacer()
                                    } else {
                                        ImageView(withURL: "https://avatars.devrant.com/" + self.rantContents.user_avatar.i!, width: 45, height: 45)
                                                .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 1.0) {
                                            Text(self.rantContents.user_username)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .scaledToFill()
                                                
                                            ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 5).fill(Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                                                Text("+" + String(self.rantContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.black)
                                            }.fixedSize()
                                        }.scaledToFit()
                                        
                                        
                                        Spacer()
                                    }
                                }
                            }
                        ).buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            Text(self.rantContents.text)
                                .padding(.trailing)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading) {
                            if self.rantContents.attached_image != nil {
                                let resizeMultiplier = self.getImageResizeMultiplier(
                                    imageWidth: CGFloat(self.rantContents.attached_image!.width!),
                                    imageHeight: CGFloat(self.rantContents.attached_image!.height!), multiplier: 1)
                                
                                //let url = File.loadFiles(images: [self.rantContents.attached_image!])[0].url
                                
                                HStack {
                                    //QLView(attachedImage: self.rantContents.attached_image!)
                                    /*TertiaryQLView(attachedImage: AttachedImage(
                                                    url: "https://img.devrant.com/devrant/rant/r_3240155_Re4L3.jpg",
                                                    width: 491,
                                                    height: 487))*/
                                    
                                    //SecondaryQLView(attachedImage: self.rantContents.attached_image!, pendingURL: url)
                                    
                                    /*ThumbnailImageView(url: self.file!.url, size: CGSize(width: CGFloat(self.rantContents.attached_image!.width!) / resizeMultiplier, height: CGFloat(self.rantContents.attached_image!.height!) / resizeMultiplier))
                                        .foregroundColor(Color(UIColor.systemBackground))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .scaledToFit()
                                        .frame(width: CGFloat(self.rantContents.attached_image!.width!) / resizeMultiplier,
                                               height: CGFloat(self.rantContents.attached_image!.height!) / resizeMultiplier)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .background(RectGetter(rect: $thumbnailRect))
                                        .onTapGesture {
                                            /*if let controller = topMostViewController() {
                                                controller.present(QLPreviewController(), animated: true, completion: nil)
                                            }*/
                                            
                                            //self.shouldPreview.toggle()
                                            let previewController = previewTestController(rect: self.thumbnailRect, url: self.file?.url)
                                            previewController.modalPresentationStyle = .overFullScreen
                                            previewController.didMove(toParent: self.viewController)
                                            //previewController.dataSource = previewControllerDataSource()
                                            self.viewController?.present(previewController, animated: true)
                                        }*/
                                    
                                    QLView(file: self.file!, parentViewController: self.viewController!)
                                    
                                    Spacer()
                                }
                                
                                
                            }
                            
                            TagCloudView(tags: self.rantContents.tags, color: Color(UIColor(hex: self.rantContents.user_avatar.b)!))
                            Divider()
                        }
                        
                        
                    }
                        //Spacer()
                }.padding([.leading, .top]).fixedSize(horizontal: false, vertical: true)
            }
            /*.fullScreenCover(isPresented: $shouldPreview) {
                PreviewControllerTest(url: self.url, isPresented: $shouldPreview).edgesIgnoringSafeArea(.all)
            }*/
            
            Spacer()
        }
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}

/*class UIRant: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}*/

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()
    var width: CGFloat
    var height: CGFloat
    
    init(withURL url: String, width: CGFloat, height: CGFloat) {
        imageLoader = ImageLoader(urlString: url)
        self.width = width
        self.height = height
    }
    
    var body: some View {
        Image(uiImage: self.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .scaledToFit()
            .frame(width: self.width, height: self.height)
            .onReceive(imageLoader.didChange) { data in
                self.image = UIImage(data: data) ?? UIImage()
        }
    }
}
