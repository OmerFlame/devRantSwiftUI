//
//  SecondaryInfiniteScroll.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/28/20.
//

import UIKit
import SwiftUI
import Combine
import TinyConstraints
import MultiplexerController

public let secondaryProfilePages: [String] = ["Rants", "++'s", "Comments", "Favorites"]

class profileViewData: ObservableObject {
    @Published var rants = [RantInFeed]()
    @Published var upvoted = [RantInFeed]()
    @Published var comments = [CommentModel]()
    @Published var favorites = [RantInFeed]()
}

class TertiaryProfileScroll: UITableViewController {
    var profileData: Profile
    var userID: Int
    @ObservedObject var profile = profileViewData()
    var supplementalImages = [UIImage?]()
    var rowHeights = [CGFloat]()
    var image: UIImage?
    
    var segmentedControl: UISegmentedControl!
    
    var testBlurView: UIVisualEffectView!
    var headerTitle: UIStackView!
    var blurView: UIVisualEffectView!
    var scoreRect: UIView!
    var scoreLabel: UILabel!
    
    var blurViewHeight = NSLayoutConstraint()
    
    var originalBlurRect: CGRect!
    var originalTitleRect: CGRect!
    var originalSmallTitleRect: CGRect!
    var originalTestRect: CGRect!
    
    var isDoneLoading = false
    
    var temporaryIndex = 0
    
    init(userID: Int, profileData: Profile, image: UIImage?) {
        self.userID = userID
        self.profileData = profileData
        super.init(style: .plain)
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInsetAdjustmentBehavior = .never
        self.navigationController?.isNavigationBarHidden = true
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if useAutosizingCells && tableView.responds(to: #selector(getter: UIView.layoutMargins)) {
            tableView.estimatedRowHeight = 150
        }
        
        let headerView = SecondaryStretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 482))
        
        headerView.containerView.backgroundColor = UIColor(hex: profileData.avatar.b)!
        headerView.imageContainer.backgroundColor = UIColor(hex: profileData.avatar.b)!
        headerView.imageView.backgroundColor = UIColor(hex: profileData.avatar.b)!
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 382, height: 382), false, CGFloat(image!.size.height / 382))
        image!.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 382, height: 382)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tableView.allowsSelection = false
        
        headerView.imageView.image = newImage
        
        tableView.tableHeaderView = headerView
        print("CONTENT OFFSET: \(tableView.contentOffset)")
        
        addTitle()
        
        blurView.contentView.isUserInteractionEnabled = true
        
        tableView.register(HostingCell<RantInFeedView>.self, forCellReuseIdentifier: "RantInFeedCell")
        tableView.register(HostingCell<Comment>.self, forCellReuseIdentifier: "CommentCell")
        
        tableView.infiniteScrollIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        tableView.infiniteScrollIndicatorMargin = 40
        tableView.infiniteScrollTriggerOffset = 500
        
        self.performFetch(nil)
        
        tableView.addInfiniteScroll { tableView -> Void in
            if self.canLoadMore() {
                self.performFetch {
                    tableView.finishInfiniteScroll()
                }
            } else {
                tableView.finishInfiniteScroll()
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.navigationController != nil {
            if !self.navigationController!.isNavigationBarHidden {
                self.navigationController?.setNavigationBarHidden(true, animated: false)
            }
        }
        
        guard tableView.tableHeaderView != nil && headerTitle != nil else { return }
        
        let offsetY = -(scrollView.contentOffset.y)
        
        let headerView = self.tableView.tableHeaderView as! SecondaryStretchyTableHeaderView
        let headerGeometry = self.geometry(view: headerView, scrollView: scrollView)
        
        let titleGeometry = self.geometry(view: headerTitle, scrollView: scrollView)
        
        (tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).containerView
            .alpha = CGFloat(sqrt(headerGeometry.largeTitleWeight))
        (tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).imageContainer.alpha = CGFloat(sqrt(headerGeometry.largeTitleWeight))
        
        let largeTitleOpacity = (max(titleGeometry.largeTitleWeight, 0.5) - 0.5) * 2
        let tinyTitleOpacity = 1 - min(titleGeometry.largeTitleWeight, 0.5) * 2
        
        headerTitle.alpha = CGFloat(sqrt(largeTitleOpacity))
        
        blurView.contentView.subviews[1].alpha = CGFloat(sqrt(tinyTitleOpacity))
        
        if let vfxSubview = blurView.subviews.first(where: {
            String(describing: type(of: $0)) == "_UIVisualEffectSubview"
        }) {
            vfxSubview.backgroundColor = UIColor.systemBackground.withAlphaComponent(0)
        }
        
        if let vfxBackdrop = blurView.subviews.first(where: {
            String(describing: type(of: $0)) == "_UIVisualEffectBackdropView"
        }) {
            vfxBackdrop.alpha = CGFloat(1 - sqrt(titleGeometry.largeTitleWeight))
        }
        
        var blurFrame = blurView.frame
        var titleFrame = headerTitle.frame
        
        blurFrame.origin.y = max(originalBlurRect.minY, originalBlurRect.minY + titleGeometry.blurOffset)
        titleFrame.origin.y = originalTitleRect.minY + 396
        
        blurView.frame = blurFrame
        headerTitle.frame = titleFrame
        
        headerView.scrollViewDidScroll(scrollView: scrollView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard segmentedControl != nil else {
            return profile.rants.count
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            return profile.rants.count
        } else if segmentedControl.selectedSegmentIndex == 1 {
            return profile.upvoted.count
        } else if segmentedControl.selectedSegmentIndex == 2 {
            return profile.comments.count
        } else {
            return profile.favorites.count
        }
    }
    
    private func canLoadMore() -> Bool {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            if tableView(tableView, numberOfRowsInSection: 0) == self.profileData.content.counts.rants {
                return false
            } else {
                return true
            }
            
        case 1:
            if tableView(tableView, numberOfRowsInSection: 0) == self.profileData.content.counts.upvoted {
                return false
            } else {
                return true
            }
            
        case 2:
            if tableView(tableView, numberOfRowsInSection: 0) == self.profileData.content.counts.comments {
                return false
            } else {
                return true
            }
            
        case 3:
            if tableView(tableView, numberOfRowsInSection: 0) == self.profileData.content.counts.favorites {
                return false
            } else {
                return true
            }
            
        default:
            fatalError("Internal inconsistency, UISegmentedControl's selected segment index is out of bounds")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch temporaryIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RantInFeedCell", for: indexPath) as! HostingCell<RantInFeedView>
            cell.set(rootView: RantInFeedView(rantContents: $profile.rants[indexPath.row], parentTableView: tableView, uiImage: supplementalImages[indexPath.row]), parentController: self, shouldLoadIntoController: true)
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RantInFeedCell", for: indexPath) as! HostingCell<RantInFeedView>
            cell.set(rootView: RantInFeedView(rantContents: $profile.upvoted[indexPath.row], parentTableView: tableView, uiImage: supplementalImages[indexPath.row]), parentController: self, shouldLoadIntoController: true)
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! HostingCell<Comment>
            cell.set(rootView: Comment(highlightColor: Color(UIColor(hex: profile.comments[indexPath.row].user_avatar.b)!), commentContents: profile.comments[indexPath.row]), parentController: self, shouldLoadIntoController: true)
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RantInFeedCell", for: indexPath) as! HostingCell<RantInFeedView>
            cell.set(rootView: RantInFeedView(rantContents: $profile.favorites[indexPath.row], parentTableView: tableView, uiImage: supplementalImages[indexPath.row]), parentController: self, shouldLoadIntoController: true)
            return cell
            
        default:
            fatalError("Internal inconsistency, UISegmentedControl's selected segment index is out of bounds")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let cell = HostingCell<RantInFeedView>()
            cell.set(rootView: RantInFeedView(rantContents: $profile.rants[indexPath.row], parentTableView: tableView, uiImage: supplementalImages[indexPath.row]), parentController: self, shouldLoadIntoController: false)
            
            return cell.hostingController.view.intrinsicContentSize.height
            
        case 1:
            let cell = HostingCell<RantInFeedView>()
            cell.set(rootView: RantInFeedView(rantContents: $profile.upvoted[indexPath.row], parentTableView: tableView, uiImage: supplementalImages[indexPath.row]), parentController: self, shouldLoadIntoController: false)
            
            return cell.hostingController.view.intrinsicContentSize.height
            
        case 2:
            let cell = HostingCell<Comment>()
            cell.set(rootView: Comment(highlightColor: Color(UIColor(hex: profile.comments[indexPath.row].user_avatar.b)!), commentContents: profile.comments[indexPath.row]), parentController: self, shouldLoadIntoController: false)
            
            return cell.hostingController.view.intrinsicContentSize.height
            
        case 3:
            let cell = HostingCell<RantInFeedView>()
            cell.set(rootView: RantInFeedView(rantContents: $profile.favorites[indexPath.row], parentTableView: tableView, uiImage: supplementalImages[indexPath.row]), parentController: self, shouldLoadIntoController: false)
            
            return cell.hostingController.view.intrinsicContentSize.height
            
        default:
            fatalError("Internal inconsistency, UISegmentedControl's selected segment index is out of bounds")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        print(self.navigationController?.description)
        print(self.navigationController?.navigationBar.description)
        
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let offsetY = -(tableView.contentOffset.y)
        
        self.navigationController!.setNavigationBarHidden(true, animated: false)
        
        scrollViewDidScroll(tableView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func addTitle() {
        let blurEffect = UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: UIScreen.main.bounds.size.width, height: 44 + 32)
        
        segmentedControl = UISegmentedControl(items: secondaryProfilePages)
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 32, height: 32)
        
        UISegmentedControl.appearance().backgroundColor = .systemBackground
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(hex: profileData.avatar.b)!
        
        segmentedControl.addTarget(self, action: #selector(selectionChanged(_:)), for: .valueChanged)
        
        let scoreSize = "+\(String(profileData.score))".boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat.greatestFiniteMagnitude), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)], context: nil).size
        scoreLabel = PaddingLabel(withInsets: 2.5, 2.5, 5, 5)
        scoreLabel.text = "+\(String(profileData.score))"
        scoreLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        scoreLabel.textColor = .black
        scoreLabel.backgroundColor = .white
        scoreLabel.layer.masksToBounds = true
        scoreLabel.layer.cornerRadius = 5
        
        let smallScoreLabel = PaddingLabel(withInsets: 2.5, 2.5, 5, 5)
        smallScoreLabel.text = "+\(String(profileData.score))"
        smallScoreLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        smallScoreLabel.textColor = .black
        smallScoreLabel.backgroundColor = .white
        smallScoreLabel.layer.masksToBounds = true
        smallScoreLabel.layer.cornerRadius = 5
        
        var largeLabelHeight = UIFont.systemFont(ofSize: 34, weight: .black).lineHeight
        var smallLabelHeight = UIFont.systemFont(ofSize: 18, weight: .bold).lineHeight
        
        print("FONT HEIGHT: \(largeLabelHeight.rounded(.up))")
        
        let bigLabelSize = profileData.username.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 32 - scoreLabel.intrinsicContentSize.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .black)], context: nil).size
        
        let smallLabelSize = profileData.username.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 32 - scoreLabel.intrinsicContentSize.width, height: CGFloat.greatestFiniteMagnitude), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)], context: nil).size
        
        let largeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bigLabelSize.width, height: largeLabelHeight.rounded(.up)))
        let smallLabel = UILabel(frame: CGRect(x: 0, y: 0, width: smallLabelSize.width, height: smallLabelHeight.rounded(.up)))
        
        //largeLabel.text = "OmerFlame"
        largeLabel.text = profileData.username
        largeLabel.font = .systemFont(ofSize: 34, weight: .black)
        largeLabel.textColor = .white
        largeLabel.adjustsFontSizeToFitWidth = true
        largeLabel.minimumScaleFactor = 0.2
        largeLabel.allowsDefaultTighteningForTruncation = true
        largeLabel.numberOfLines = 1
        
        smallLabel.text = profileData.username
        smallLabel.font = .systemFont(ofSize: 18, weight: .bold)
        smallLabel.textColor = .label
        smallLabel.adjustsFontSizeToFitWidth = true
        smallLabel.minimumScaleFactor = 0.1
        smallLabel.allowsDefaultTighteningForTruncation = true
        smallLabel.numberOfLines = 1
        
        largeLabel.translatesAutoresizingMaskIntoConstraints = false
        smallLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerTitle = UIStackView(frame: CGRect(x: 0, y: 0, width: largeLabel.frame.size.width + 5 + scoreLabel.intrinsicContentSize.width, height: max(largeLabel.frame.size.height, scoreLabel.intrinsicContentSize.height)))
        
        headerTitle.axis = .horizontal
        headerTitle.alignment = .center
        headerTitle.distribution = .equalCentering
        
        headerTitle.addArrangedSubview(largeLabel)
        headerTitle.addArrangedSubview(scoreLabel)
        
        let smallHeaderTitle = UIStackView(frame: CGRect(x: 0, y: 0, width: smallLabel.frame.size.width + 5 + smallScoreLabel.intrinsicContentSize.width, height: max(smallLabel.frame.size.height, smallScoreLabel.intrinsicContentSize.height)))
        
        smallHeaderTitle.axis = .horizontal
        smallHeaderTitle.alignment = .center
        smallHeaderTitle.distribution = .equalCentering
        
        smallHeaderTitle.addArrangedSubview(smallLabel)
        smallHeaderTitle.addArrangedSubview(smallScoreLabel)
        
        blurView.contentView.addSubview(headerTitle)
        blurView.contentView.addSubview(smallHeaderTitle)
        blurView.contentView.addSubview(segmentedControl)
        tableView.tableHeaderView!.addSubview(blurView)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.heightAnchor.constraint(equalTo: tableView.tableHeaderView!.heightAnchor).isActive = true
        
        blurView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
        
        largeLabel.translatesAutoresizingMaskIntoConstraints = false
        smallLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.leadingAnchor.constraint(equalTo: largeLabel.trailingAnchor, constant: 5).isActive = true
        
        largeLabel.centerYAnchor.constraint(equalTo: largeLabel.superview!.centerYAnchor).isActive = true
        
        smallHeaderTitle.translatesAutoresizingMaskIntoConstraints = false
        smallHeaderTitle.insetsLayoutMarginsFromSafeArea = false
        
        smallScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        smallScoreLabel.leadingAnchor.constraint(equalTo: smallLabel.trailingAnchor, constant: 5).isActive = true
        smallScoreLabel.bottomAnchor.constraint(equalTo: smallLabel.bottomAnchor).isActive = true
        
        smallHeaderTitle.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor).isActive = true
        smallHeaderTitle.heightAnchor.constraint(equalToConstant: max(smallLabel.frame.size.height, smallScoreLabel.intrinsicContentSize.height)).isActive = true
        smallHeaderTitle.widthAnchor.constraint(equalToConstant: smallLabel.frame.size.width + 5 + smallScoreLabel.intrinsicContentSize.width).isActive = true
        smallHeaderTitle.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: -8).isActive = true
        
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        
        headerTitle.bottomAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: -8).isActive = true
        headerTitle.widthAnchor.constraint(equalToConstant: largeLabel.frame.size.width + 5 + scoreLabel.intrinsicContentSize.width).isActive = true
        
        headerTitle.heightAnchor.constraint(equalToConstant: max(largeLabel.frame.size.height, scoreLabel.intrinsicContentSize.height)).isActive = true
        
        largeLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 16).isActive = true
        
        originalBlurRect = blurView.frame
        originalTitleRect = headerTitle.frame
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -8).isActive = true
        segmentedControl.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 32).isActive = true
        segmentedControl.heightAnchor.constraint(equalToConstant: 32).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 16).isActive = true
        
        if let v = tableView.tableHeaderView as? SecondaryStretchyTableHeaderView {
            v.segControl = segmentedControl
        }
        
        headerTitle.updateConstraints()
        
        scrollViewDidScroll(tableView)
    }
    
    @objc func selectionChanged(_ sender: UISegmentedControl) {
        print("Selection changed to \(secondaryProfilePages[sender.selectedSegmentIndex])")
        //tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        //tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
        self.profile.rants = []
        self.profile.upvoted = []
        self.profile.comments = []
        self.profile.favorites = []
        self.supplementalImages = []
        
        self.tableView.reloadData()
        temporaryIndex = segmentedControl.selectedSegmentIndex
        //self.tableView.beginInfiniteScroll(true)
        performFetch(nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            (blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1].backgroundColor = .white
            ((blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1] as! UILabel).textColor = .black
        } else {
            //(blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1].backgroundColor = .black
            //((blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1] as! UILabel).textColor = .white
        }
        
        scrollViewDidScroll(tableView)
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
    
    func findViewInViewHierarchy(withRootView view: UIView, destinationType: String) -> [UIView] {
        let subviews = view.subviews
        
        guard subviews.count != 0 else { return [] }
        
        var capturedViews: [UIView] = []
        
        capturedViews = subviews.filter { String(describing: type(of: $0)) == destinationType }
        
        for subview in subviews {
            //print(subview.description)
            
            capturedViews.append(contentsOf: findViewInViewHierarchy(withRootView: subview, destinationType: destinationType))
        }
        
        return capturedViews
    }
    
    fileprivate func performFetch(_ completionHandler: (() -> Void)?) {
        getRants { result in
            defer { completionHandler?() }
            
            var rantSequence: EnumeratedSequence<[RantInFeed]>?
            var commentSequence: EnumeratedSequence<[CommentModel]>?
            
            
            
            switch result != nil {
            case true:
                var start: Int!
                var end: Int!
                
                var count: Int {
                    if self.segmentedControl.selectedSegmentIndex == 0 {
                        rantSequence = result!.profile.content.content.rants.enumerated()
                        
                        start = self.profile.rants.count
                        end = result!.profile.content.content.rants.count + start
                        
                        return self.profile.rants.count
                    } else if self.segmentedControl.selectedSegmentIndex == 1 {
                        rantSequence = result!.profile.content.content.upvoted.enumerated()
                        
                        start = self.profile.upvoted.count
                        end = result!.profile.content.content.upvoted.count + start
                        
                        return self.profile.upvoted.count
                    } else if self.segmentedControl.selectedSegmentIndex == 2 {
                        commentSequence = result!.profile.content.content.comments.enumerated()
                        
                        start = self.profile.comments.count
                        end = result!.profile.content.content.comments.count + start
                        
                        return self.profile.comments.count
                    } else {
                        rantSequence = result!.profile.content.content.favorites!.enumerated()
                        
                        start = self.profile.favorites.count
                        end = result!.profile.content.content.favorites!.count + start
                        
                        return self.profile.favorites.count
                    }
                }
                
                print(count)
                
                /**
                 NOTE ABOUT THE `print(count)` LINE:
                 In order to set the values of `start` and `end`, I had to engage with the `count` variable calculation initializer. I wrote this system in a TERRIBLE way and I 100% will remake this in the future. I honestly don't know what I was thinking to myself, because this is ridiculously stupid. I made this code WAY more complicated than what it should've been and I will try to make it better in the future.
                 */
                
                let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    self.profile.rants.append(contentsOf: result!.profile.content.content.rants)
                } else if self.segmentedControl.selectedSegmentIndex == 1 {
                    self.profile.upvoted.append(contentsOf: result!.profile.content.content.upvoted)
                } else if self.segmentedControl.selectedSegmentIndex == 2 {
                    self.profile.comments.append(contentsOf: result!.profile.content.content.comments)
                } else {
                    self.profile.favorites.append(contentsOf: result!.profile.content.content.favorites!)
                }
                
                if rantSequence != nil {
                    for (idx, rant) in rantSequence! {
                        if rant.attached_image != nil {
                            let completionSemaphore = DispatchSemaphore(value: 0)
                            
                            var image = UIImage()
                            
                            URLSession.shared.dataTask(with: URL(string: (rant.attached_image?.url!)!)!) { data, _, _ in
                                image = UIImage(data: data!)!
                                
                                completionSemaphore.signal()
                            }.resume()
                            
                            completionSemaphore.wait()
                            let resizeMultiplier = self.getImageResizeMultiplier(imageWidth: image.size.width, imageHeight: image.size.height, multiplier: 1)
                            
                            let finalSize = CGSize(width: image.size.width / resizeMultiplier, height: image.size.height / resizeMultiplier)
                            
                            UIGraphicsBeginImageContextWithOptions(finalSize, false, resizeMultiplier)
                            image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: finalSize))
                            let newImage = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            
                            self.supplementalImages.append(newImage)
                        } else {
                            self.supplementalImages.append(nil)
                        }
                    }
                }
                
                if commentSequence != nil {
                    for (idx, comment) in commentSequence! {
                        if comment.attached_image != nil {
                            let completionSemaphore = DispatchSemaphore(value: 0)
                            
                            var image = UIImage()
                            
                            URLSession.shared.dataTask(with: URL(string: (comment.attached_image?.url!)!)!) { data, _, _ in
                                image = UIImage(data: data!)!
                                
                                completionSemaphore.signal()
                            }.resume()
                            
                            completionSemaphore.wait()
                            let resizeMultiplier = self.getImageResizeMultiplier(imageWidth: image.size.width, imageHeight: image.size.height, multiplier: 1)
                            
                            let finalSize = CGSize(width: image.size.width / resizeMultiplier, height: image.size.height / resizeMultiplier)
                            
                            UIGraphicsBeginImageContextWithOptions(finalSize, false, resizeMultiplier)
                            image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: finalSize))
                            let newImage = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                            
                            self.supplementalImages.append(newImage)
                        } else {
                            self.supplementalImages.append(nil)
                        }
                    }
                }
                
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .automatic)
                self.tableView.endUpdates()
                
                self.scrollViewDidScroll(self.tableView)
                
                break
                
            case false:
                self.showAlertWithError("Failed to fetch user content")
            }
        }
    }
    
    fileprivate func showAlertWithError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.performFetch(nil) }))
        present(alert, animated: true, completion: nil)
    }
    
    func getRants(completion: @escaping ((ProfileResponse?) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            var skipCounter = 0
            
            var contentType: ProfileContentTypes {
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    skipCounter = self.profile.rants.count
                    return .rants
                } else if self.segmentedControl.selectedSegmentIndex == 1 {
                    skipCounter = self.profile.upvoted.count
                    return .upvoted
                } else if self.segmentedControl.selectedSegmentIndex == 2 {
                    skipCounter = self.profile.comments.count
                    return .comments
                } else {
                    skipCounter = self.profile.favorites.count
                    return .favorite
                }
            }
            
            DispatchQueue.global(qos: .background).sync {
                do {
                    let content = try APIRequest().getProfileFromID(self.userID, userContentType: contentType, skip: skipCounter)
                    
                    DispatchQueue.main.async {
                        completion(content)
                    }
                } catch let error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
}

extension TertiaryProfileScroll {
    struct HeaderGeometry {
        let width: CGFloat
        let headerHeight: CGFloat
        let elementsHeight: CGFloat
        let headerOffset: CGFloat
        let blurOffset: CGFloat
        let elementsOffset: CGFloat
        let largeTitleWeight: Double
    }
    
    func geometry(view: UIView, scrollView: UIScrollView) -> HeaderGeometry {
        let safeArea = scrollView.safeAreaInsets
        
        let minY = -(scrollView.contentOffset.y + scrollView.safeAreaInsets.top)
        
        let hasScrolledUp = minY > 0
        
        let hasScrolledToMinHeight = -minY >= 450 - 47 - safeArea.top

        let headerHeight = hasScrolledUp ?
            (tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).containerView.frame.size.height + minY + 32 : (tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).containerView.frame.size.height + 32

        let elementsHeight = (tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).frame.size.height + minY

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
            headerOffset = -minY - 450 + 47 + safeArea.top
            blurOffset = -minY - 450 + 47 + safeArea.top - 32
            elementsOffset = headerOffset / 2 - minY / 2
            largeTitleWeight = 0
        } else {
            headerOffset = 0
            blurOffset = 0
            elementsOffset = -minY / 2
            let difference = 450 - 47 - safeArea.top + minY
            largeTitleWeight = difference <= 47 + 1 ? Double(difference / (47 + 1)) : 1
        }
        
        return HeaderGeometry(width: (tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).frame.size.width, headerHeight: headerHeight, elementsHeight: elementsHeight, headerOffset: headerOffset, blurOffset: blurOffset, elementsOffset: elementsOffset, largeTitleWeight: largeTitleWeight)
    }
}

struct TertiaryProfileScrollSwiftUI: UIViewControllerRepresentable {
    let userID: Int
    @Binding var profileData: Profile?
    @Binding var image: UIImage?
    
    init(userID: Int, profileData: Binding<Profile?>, image: Binding<UIImage?>) {
        self.userID = userID
        self._profileData = profileData
        self._image = image
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return TertiaryProfileScroll(userID: self.userID, profileData: self.profileData!, image: self.image)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

public func map(_ x: CGFloat, _ inMin: CGFloat, _ inMax: CGFloat, _ outMin: CGFloat, _ outMax: CGFloat) -> CGFloat {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

