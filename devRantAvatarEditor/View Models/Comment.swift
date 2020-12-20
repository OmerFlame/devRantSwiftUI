//
//  Comment.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/14/20.
//

import SwiftUI

public struct Comment: View {
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    let highlightColor: Color
    @State var commentContents: CommentModel
    
    @State var profileData: Profile? = nil
    @State var image: UIImage? = nil
    
    @State var shouldNavigate = false
    
    @State var shouldShowError = false
    
    public var body: some View {
        HStack {
            VStack {
                HStack(alignment: .top) {
                    VStack(spacing: 1) {
                        Button(action: {
                            var vote: Int {
                                switch self.commentContents.vote_state {
                                case 0:
                                    return 1
                                    
                                case 1:
                                    return 0
                                    
                                default:
                                    return 1
                                }
                            }
                            
                            let success = APIRequest().voteOnComment(commentID: self.commentContents.id, vote: vote)
                            
                            if !success {
                                self.shouldShowError.toggle()
                            } else {
                                self.commentContents.vote_state = vote
                            }
                        }, label: {
                            if self.commentContents.vote_state == 1 {
                                Image("plusplus").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.commentContents.user_avatar.b)!))
                            } else if self.commentContents.vote_state == 0 {
                                Image("plusplus").accentColor(.gray).font(.system(size: 25))
                            } else {
                                Image("plusplus").accentColor(.gray).font(.system(size: 25))
                            }
                        }).disabled(self.commentContents.vote_state == -2)
                        Text(String(self.commentContents.score)).font(.subheadline)
                        Button(action: {
                            var vote: Int {
                                switch self.commentContents.vote_state {
                                case 0:
                                    return -1
                                    
                                case -1:
                                    return 0
                                    
                                default:
                                    return -1
                                }
                            }
                            
                            let success = APIRequest().voteOnComment(commentID: self.commentContents.id, vote: vote)
                            
                            if !success {
                                self.shouldShowError.toggle()
                            } else {
                                self.commentContents.vote_state = vote
                            }
                        }, label: {
                            if self.commentContents.vote_state == -1 {
                                Image("minusminus").font(.system(size: 25)).accentColor(Color(UIColor(hex: self.commentContents.user_avatar.b)!))
                            } else if self.commentContents.vote_state == 0 {
                                Image("minusminus").accentColor(.gray).font(.system(size: 25))
                            } else {
                                Image("minusminus").accentColor(.gray).font(.system(size: 25))
                            }
                        }).disabled(self.commentContents.vote_state == -2)
                    }
                    
                    
                    //.scaledToFill()
                    
                    VStack {
                        NavigationLink(
                            
                            destination: LazyView(TertiaryProfileScrollSwiftUI(userID: self.commentContents.user_id, profileData: $profileData, image: $image))
                                .edgesIgnoringSafeArea(.top)
                                .navigationBarHidden(true)
                                .navigationBarBackButtonHidden(true),
                            
                            isActive: $shouldNavigate,
                            
                            label: {
                                HStack {
                                    if self.commentContents.user_avatar.i == nil {
                                        let color = UIColor(hex: self.commentContents.user_avatar.b)
                                        
                                        Circle()
                                            .size(CGSize(width: 45, height: 45))
                                            .fill(Color(color!))
                                            .frame(width: 45, height: 45)
                                            //.padding(.trailing)
                                        
                                        VStack(alignment: .leading, spacing: 1.0) {
                                            Text(self.commentContents.user_username)
                                                .fixedSize(horizontal: true, vertical: false)
                                                //.scaledToFill()
                                            
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 5).fill(Color(color!))
                                                Text("+" + String(self.commentContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.white)
                                            }.fixedSize()
                                        }.scaledToFit()
                                        
                                        Spacer()
                                    } else {
                                        ImageView(withURL: "https://avatars.devrant.com/" + self.commentContents.user_avatar.i!, width: 45, height: 45)
                                                .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 1.0) {
                                            Text(self.commentContents.user_username).fixedSize(horizontal: false, vertical: true).fixedSize(horizontal: true, vertical: false)
                                                
                                            ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 5).fill(Color(UIColor(hex: self.commentContents.user_avatar.b)!))
                                                Text("+" + String(self.commentContents.user_score)).padding(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5)).font(.caption).foregroundColor(.black)
                                            }.fixedSize()
                                        }.scaledToFit()
                                        
                                        
                                        Spacer()
                                    }
                                }.onTapGesture {
                                    self.getProfile()
                                    
                                    if self.profileData != nil {
                                        if self.profileData!.avatar.i != nil {
                                            self.getRanterImage()
                                        }
                                        
                                        self.shouldNavigate.toggle()
                                    } else {
                                        self.shouldShowError.toggle()
                                    }
                                }
                            }
                        ).buttonStyle(PlainButtonStyle())
                        
                        HStack {
                            Text(self.commentContents.body)
                                .padding(.trailing)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                        
                        if self.commentContents.attached_image != nil {
                            let resizeMultiplier = self.getImageResizeMultiplier(
                                imageWidth: CGFloat(self.commentContents.attached_image!.width!),
                                imageHeight: CGFloat(self.commentContents.attached_image!.height!), multiplier: 1)
                            
                            //let url = File.loadFiles(images: [self.commentContents.attached_image!])[0].url
                            
                            let finalWidth = CGFloat(commentContents.attached_image!.width!) / resizeMultiplier
                            let finalHeight = CGFloat(commentContents.attached_image!.height!) / resizeMultiplier
                            
                            let file = File.loadFile(image: commentContents.attached_image!, size: CGSize(width: finalWidth, height: finalHeight))
                            
                            HStack {
                                //SecondaryQLView(attachedImage: self.commentContents.attached_image!, pendingURL: url)
                                
                                QLView(file: file, parentViewController: self.viewController!)
                                
                                Spacer()
                            }
                        }
                        
                        //Divider()
                    }
                        
                        //Spacer()
                }.padding([.leading, .top]).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func getRanterImage() {
        let completionSemaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: URL(string: "https://avatars.devrant.com/\(self.profileData!.avatar.i!)")!) { data, _, _ in
            self.image = UIImage(data: data!)
            
            completionSemaphore.signal()
        }.resume()
        
        completionSemaphore.wait()
        return
    }
    
    private func getProfile() {
        do {
            self.profileData = try APIRequest().getProfileFromID(self.commentContents.user_id, userContentType: .rants, skip: 0)?.profile
        } catch {
            DispatchQueue.main.async {
                self.shouldShowError.toggle()
            }
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

final class SecondaryComment: UITableViewCell {
    var highlightColor: UIColor?
    var commentContents: CommentModel?
    
    var profileData: Profile?
    var supplementalImage: UIImage?
    
    @State var shouldNavigate = false
    
    @State var shouldShowError = false
    
    var upvoteButton: UIButton!
    var rantScoreLabel: UILabel!
    var downvoteButton: UIButton!
    var rantText: UILabel!
    
    var container = UIView()
    
    var rantScoreConstraint = NSLayoutConstraint()
    
    func setData(commentContents: CommentModel) {
        self.commentContents = commentContents
        self.highlightColor = UIColor(hex: commentContents.user_avatar.b)!
        
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        
        for view in container.subviews {
            view.removeFromSuperview()
        }
        
        container = UIView()
        
        contentView.addSubview(container)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        upvoteButton = UIButton()
        upvoteButton.setImage(UIImage(named: "plusplus"), for: .normal)
        upvoteButton.tintColor = .gray
        
        if !self.container.subviews.contains(upvoteButton) {
            container.addSubview(upvoteButton)
            
            upvoteButton.translatesAutoresizingMaskIntoConstraints = false
            upvoteButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 4).isActive = true
            upvoteButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8).isActive = true
            upvoteButton.heightAnchor.constraint(equalToConstant: UIImage(named: "plusplus")!.size.height).isActive = true
        }
        
        rantScoreLabel = UILabel()
        rantScoreLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        rantScoreLabel.text = String(commentContents.score)
        
        if !self.container.subviews.contains(rantScoreLabel) {
            container.addSubview(rantScoreLabel)
            
            rantScoreLabel.translatesAutoresizingMaskIntoConstraints = false
            
            rantScoreLabel.topAnchor.constraint(equalTo: upvoteButton.bottomAnchor).isActive = true
            rantScoreLabel.centerXAnchor.constraint(equalTo: upvoteButton.centerXAnchor).isActive = true
            rantScoreConstraint = rantScoreLabel.heightAnchor.constraint(equalToConstant: 24)
            rantScoreConstraint.isActive = true
            rantScoreConstraint.priority = UILayoutPriority.init(999)
        }
        
        
        downvoteButton = UIButton()
        downvoteButton.setImage(UIImage(named: "minusminus"), for: .normal)
        downvoteButton.tintColor = .gray
        
        downvoteButton.frame.size.height = UIImage(named: "minusminus")!.size.height
        
        if !self.container.subviews.contains(downvoteButton) {
            container.addSubview(downvoteButton)
            
            downvoteButton.translatesAutoresizingMaskIntoConstraints = false
            
            downvoteButton.topAnchor.constraint(equalTo: rantScoreLabel.bottomAnchor).isActive = true
            downvoteButton.centerXAnchor.constraint(equalTo: upvoteButton.centerXAnchor).isActive = true
            //downvoteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
            //downvoteButton.heightAnchor.constraint(equalToConstant: UIImage(named: "minusminus")!.size.height).isActive = true
            downvoteButton.frame = downvoteButton.imageView!.frame
        }
        
        rantText = UILabel()
        rantText.font = UIFont.preferredFont(forTextStyle: .body)
        rantText.lineBreakMode = .byWordWrapping
        rantText.numberOfLines = .max
        rantText.text = commentContents.body
        
        if !self.container.subviews.contains(rantText) {
            container.addSubview(rantText)
            
            rantText.translatesAutoresizingMaskIntoConstraints = false
            
            rantText.topAnchor.constraint(equalTo: container.topAnchor, constant: 4).isActive = true
            rantText.leadingAnchor.constraint(equalTo: upvoteButton.trailingAnchor, constant: 4).isActive = true
            rantText.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8).isActive = true
            //rantText.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4).isActive = true
        }
        
        if downvoteButton.frame.maxY > rantText.frame.maxY {
            downvoteButton.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        } else {
            rantText.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        }
    }
}

struct Comment_Previews: PreviewProvider {
    static var previews: some View {
        Comment(highlightColor: Color.red,
                commentContents: CommentModel(
                    id: 3290854,
                    rant_id: 3290301,
                    body: "Senior dev: It'd better be Liit",
                    score: 0,
                    created_time: 1603125848,
                    vote_state: 0,
                    links: nil,
                    user_id: 3290286,
                    user_username: "ashinsiider",
                    user_score: 1,
                    user_avatar: UserAvatar(
                        b: "7bc8a4",
                        //i: "v-37_c-3_b-2_g-m_9-1_1-6_16-4_3-6_8-4_7-4_5-4_12-6_17-2_6-15_2-26_22-7_15-3_11-3_18-4_19-4_4-4_20-1_21-1.jpg"
                        i: nil
                    ),
                    user_dpp: nil,
                    attached_image: nil /*AttachedImage(
                        url: "https://avatars.devrant.com/v-37_c-1_b-5_g-m_9-1_1-1_16-7_3-2_8-2_7-2_5-1_12-1_6-97_10-9_2-90_22-7_11-8_18-3_19-2_4-1_20-2.png",
                        width: 1400,
                        height: 1400)*/
                ))
    }
}
