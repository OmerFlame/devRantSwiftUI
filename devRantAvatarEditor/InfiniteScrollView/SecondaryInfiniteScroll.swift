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

public let secondaryProfilePages: [String] = ["Rants", "++'s", "Comments", "Favorites"]

class SecondaryProfileInfiniteScroll: UITableViewController {
    @ObservedObject var content = rantFeedData()
    var supplementalImages = [UIImage?]()
    var isComplete = false
    fileprivate var currentPage = 0
    var userID: Int
    var userInfo: Profile? = nil
    
    var skipCounter = 0
    
    var image: UIImage?
    @State var imageOpacity: Double = 1
    
    init(userID: Int) {
        self.userID = userID
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var hostingHeader = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if useAutosizingCells && tableView.responds(to: #selector(getter: UIView.layoutMargins)) {
            tableView.estimatedRowHeight = 88
            tableView.rowHeight = UITableView.automaticDimension
        }
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        tableView.addSubview(activityIndicator)
        
        activityIndicator.centerInSuperview()
        
        let completionSemaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                self.userInfo = try APIRequest().getProfileFromID(self.userID, userContentType: .rants, skip: 0)!.profile
                UISegmentedControl.appearance().backgroundColor = .systemBackground
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(hex: self.userInfo!.avatar.b)
                
                if self.userInfo?.avatar.i != nil {
                    self.getImage()
                }
                
                self.isComplete = true
                completionSemaphore.signal()
            } catch let error {
                print(error.localizedDescription)
                self.userInfo = nil
            }
        }
        
        //view.insetsLayoutMarginsFromSafeArea = false
        
        completionSemaphore.wait()
        let imageHeader = Header(imageOpacity: 1.0, image: self.image!, userAvatar: self.userInfo!.avatar)
        
        /*let hostingHeader = UIHostingController(rootView: HeaderScrollView(title: self.userInfo!.username,
                                                                           upvotes: self.userInfo!.score,
                                                                           pageSelection: self.$viewSelection,
                                                                           opacity: imageHeader.imageOpacity,
                                                                           headerHeight: 450,
                                                                           scrollUpBehavior: .parallax,
                                                                           scrollDownBehavior: .offset,
                                                                           header: imageHeader,
                                                                           content: nil).headerOnly).view*/
        
        self.hostingHeader = UIHostingController(rootView: HeaderView(title: self.userInfo!.username,
                                                                     upvotes: self.userInfo!.score,
                                                                     opacity: imageHeader.imageOpacity,
                                                                     headerHeight: 450,
                                                                     scrollUpBehavior: .parallax,
                                                                     scrollDownBehavior: .offset,
                                                                     header: imageHeader)).view
        
        let headerView = UIHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        
        headerView.imageView.image = UIImage(named: "background_image")
        
        //tableView.tableHeaderView = hostingHeader
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.tableHeaderView?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        //setupHeaderView()
        
        //hostingHeader!.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 450)
        
        tableView.infiniteScrollIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        tableView.infiniteScrollIndicatorMargin = 40
        tableView.infiniteScrollTriggerOffset = 500
        
        tableView.separatorStyle = .none
        
        tableView.register(HostingCell<RantInFeedView>.self, forCellReuseIdentifier: "HostingCell")
        
        tableView.addInfiniteScroll { tableView -> Void in
            self.performFetch {
                tableView.finishInfiniteScroll()
                
                if self.content.rantFeed.count == 30 {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    //self.refreshControl!.endRefreshing()
                }
            }
        }
        
        tableView.beginInfiniteScroll(true)
        
        //hostingHeader?.clipsToBounds = true
        
        //self.tableView.tableHeaderView = hostingHeader
        
        tableView.tableHeaderView?.isUserInteractionEnabled = true
        //tableView.contentInset = UIEdgeInsets(top: 450, left: 0, bottom: 0, right: 0)
        //tableView.contentOffset = CGPoint(x: 0, y: -450)
        //tableView.tableHeaderView?.insetsLayoutMarginsFromSafeArea = false
        
        //view.insetsLayoutMarginsFromSafeArea = false
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //super.scrollViewDidScroll(scrollView)
        
        //updateTableHeader()
        
        let headerView = self.tableView.tableHeaderView as! UIHeaderView
        headerView.scrollViewDidScroll(scrollView: scrollView)
    }
    
    fileprivate func performFetch(_ completionHandler: (() -> Void)?) {
        getRants { result in
            defer { completionHandler?() }
            
            switch result != nil {
            case true:
                let count = self.content.rantFeed.count
                let (start, end) = (count, result!.profile.content.content.rants.count + count)
                let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                
                self.content.rantFeed.append(contentsOf: result!.profile.content.content.rants)
                
                for (idx, rant) in result!.profile.content.content.rants.enumerated() {
                    if rant.attached_image != nil {
                        let completionSemaphore = DispatchSemaphore(value: 0)
                        
                        var image = UIImage()
                        
                        URLSession.shared.dataTask(with: URL(string: (result!.profile.content.content.rants[idx].attached_image?.url!)!)!) { data, _, _ in
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
                
                self.currentPage += 1
                
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .automatic)
                self.tableView.endUpdates()
                
                break
                
            case false:
                self.showAlertWithError("Failed to fetch rants")
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
    
    func getRants(completion: @escaping ((ProfileResponse?) -> Void)) {
        /*do {
            self.content += try APIRequest().getProfileFromID(self.userID, userContentType: .rants, skip: 0)!.profile.content.content.rants
        } catch let error {
            print(error.localizedDescription)
            self.content += []
        }*/
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds((content.rantFeed.count == 0 ? 0 : 1))) {
            do {
                let content = try APIRequest().getProfileFromID(self.userID, userContentType: .rants, skip: self.skipCounter)
                
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
    
    func updateTableHeader() {
        var headerFrame = CGRect(x: 0, y: -450, width: tableView.bounds.width, height: 450)
        
        if tableView.contentOffset.y < -450 {
            headerFrame.origin.y = tableView.contentOffset.y
            headerFrame.size.height = -tableView.contentOffset.y
        }
        
        hostingHeader.frame = headerFrame
    }
    
    func setupHeaderView() {
        hostingHeader = tableView.tableHeaderView ?? UIView()
        tableView.tableHeaderView = nil
        tableView.addSubview(hostingHeader)
        tableView.contentInset = UIEdgeInsets(top: 450, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -450)
        updateTableHeader()
    }
    
    fileprivate func showAlertWithError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.performFetch(nil) }))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = ""
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.rantFeed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rant = $content.rantFeed[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostingCell", for: indexPath) as! HostingCell<RantInFeedView>
        
        cell.set(rootView: RantInFeedView(rantContents: rant, uiImage: supplementalImages[indexPath.row]), parentController: self)
        
        return cell
    }
}

struct SecondaryProfileRepresentable: UIViewControllerRepresentable {
    let userID: Int
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return SecondaryProfileInfiniteScroll(userID: self.userID)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class profileViewData: ObservableObject {
    //@Published var data: Profile? = nil
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
        //self.profile.rants = profileData.content.content.rants
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInsetAdjustmentBehavior = .never
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        print("IS NAVIGATION BAR HIDDEN: \(self.navigationController?.isNavigationBarHidden)")
        
        
        //navigationController?.isNavigationBarHidden = true
        
        //let navBar = findViewInViewHierarchy(withRootView: UIApplication.shared.windows.first!.rootViewController!.view, destinationType: "UINavigationBar")
        
        /*if !navBar.isEmpty {
            navBar[0].isHidden = true
        }*/
        
        
        if useAutosizingCells && tableView.responds(to: #selector(getter: UIView.layoutMargins)) {
            tableView.estimatedRowHeight = 150
            tableView.rowHeight = UITableView.automaticDimension
        }
        
        let headerView = SecondaryStretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 482))
        
        headerView.containerView.backgroundColor = UIColor(hex: profileData.avatar.b)!
        headerView.imageContainer.backgroundColor = UIColor(hex: profileData.avatar.b)!
        headerView.imageView.backgroundColor = UIColor(hex: profileData.avatar.b)!
        //let image = UIImage(named: "background_image")
        
        //UIGraphicsBeginImageContextWithOptions(CGSize(width: 350, height: 350), false, 4)
        //image!.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 350, height: 350)))
        
        //UIGraphicsBeginImageContextWithOptions(CGSize(width: 388, height: 388), false, 3.6082474226804123)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 382, height: 382), false, CGFloat(image!.size.height / 382))
        image!.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 382, height: 382)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tableView.allowsSelection = false
        
        headerView.imageView.image = newImage
        
        tableView.tableHeaderView = headerView
        print("CONTENT OFFSET: \(tableView.contentOffset)")
        
        addTitle()
        
        //tableView.contentOffset.y -= 32
        
        //blurView.contentView.subviews[1].bounds = blurView.contentView.subviews[1].frame.inset(by: UIEdgeInsets(top: -view.safeAreaInsets.top, left: 0, bottom: 0, right: 0))
        
        blurView.contentView.isUserInteractionEnabled = true
        
        tableView.register(HostingCell<RantInFeedView>.self, forCellReuseIdentifier: "RantInFeedCell")
        tableView.register(HostingCell<Comment>.self, forCellReuseIdentifier: "CommentCell")
        
        tableView.infiniteScrollIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        tableView.infiniteScrollIndicatorMargin = 40
        tableView.infiniteScrollTriggerOffset = 500
        
        self.performFetch(nil)
        
        tableView.addInfiniteScroll { tableView -> Void in
            
            //let count = self.profile.rants.count
            //let (start, end) = (0, count)
            //let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
            
            //self.currentPage += 1
            
            //self.tableView.beginUpdates()
            //self.tableView.insertRows(at: indexPaths, with: .automatic)
            //self.tableView.endUpdates()
            
            //tableView.finishInfiniteScroll()
            //tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            
            //self.isDoneLoading = true
            
            self.performFetch {
                tableView.finishInfiniteScroll()
                
                /*if self.profile.rants.count == 30 {
                    tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                }*/
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        print("IS NAVIGATION BAR HIDDEN: \(self.navigationController?.isNavigationBarHidden)")
        
        
        guard tableView.tableHeaderView != nil && headerTitle != nil else { return }
        
        let offsetY = -(scrollView.contentOffset.y)
        
        print("Y OFFSET: \(offsetY)")
        
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
            //vfxSubview.backgroundColor = UIColor.systemBackground.withAlphaComponent(map(CGFloat(1 - sqrt(titleGeometry.largeTitleWeight)), 0.0, 1.0, 0.0, 0.7))
            vfxSubview.backgroundColor = UIColor.systemBackground.withAlphaComponent(0)
        }
        
        if let vfxBackdrop = blurView.subviews.first(where: {
            String(describing: type(of: $0)) == "_UIVisualEffectBackdropView"
        }) {
            //vfxBackdrop.alpha = CGFloat(1 - sqrt(titleGeometry.largeTitleWeight))
            vfxBackdrop.alpha = CGFloat(1 - sqrt(titleGeometry.largeTitleWeight))
        }
        
        var blurFrame = blurView.frame
        var titleFrame = headerTitle.frame
        
        print("LAST MIN-Y: \(blurFrame.origin.y)")
        print("BLUR OFFSET: \(titleGeometry.blurOffset)")
        
        blurFrame.origin.y = max(originalBlurRect.minY, originalBlurRect.minY + titleGeometry.blurOffset)
        //titleFrame.origin.y = originalTitleRect.minY + 364
        titleFrame.origin.y = originalTitleRect.minY + 396
        
        blurView.frame = blurFrame
        headerTitle.frame = titleFrame
        
        
        
        print("NEW MIN-Y: \(blurView.frame.origin.y)")
        
        headerView.scrollViewDidScroll(scrollView: scrollView)
        
        //blurViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        print("REQUESTED INDEX: \(indexPath.row)")
        
        //print(self.navigationController?.description)
        
        /*let navBar = findViewInViewHierarchy(withRootView: UIApplication.shared.windows.first!.rootViewController!.view, destinationType: "UINavigationBar")
        
        if !navBar.isEmpty {
            navBar[0].isHidden = true
        }*/
        
        switch temporaryIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RantInFeedCell", for: indexPath) as! HostingCell<RantInFeedView>
            cell.set(rootView: RantInFeedView(rantContents: $profile.rants[indexPath.row], uiImage: supplementalImages[indexPath.row]), parentController: self)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RantInFeedCell", for: indexPath) as! HostingCell<RantInFeedView>
            cell.set(rootView: RantInFeedView(rantContents: $profile.upvoted[indexPath.row], uiImage: supplementalImages[indexPath.row]), parentController: self)
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! HostingCell<Comment>
            cell.set(rootView: Comment(highlightColor: Color(UIColor(hex: profile.comments[indexPath.row].user_avatar.b)!), commentContents: profile.comments[indexPath.row]), parentController: self)
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RantInFeedCell", for: indexPath) as! HostingCell<RantInFeedView>
            cell.set(rootView: RantInFeedView(rantContents: $profile.favorites[indexPath.row], uiImage: supplementalImages[indexPath.row]), parentController: self)
            return cell
            
        default:
            fatalError("Internal inconsistency, UISegmentedControl's selected segment index is out of bounds")
        }
        
        //view.sendSubviewToBack(cell!)
        //view.bringSubviewToFront(tableView.tableHeaderView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.isHidden = true
        //navigationController?.navigationBar.isTranslucent = false
        self.navigationController!.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        //let navBar = findViewInViewHierarchy(withRootView: UIApplication.shared.windows.first!.rootViewController!.view, destinationType: "UINavigationBar")
        
        /*if !navBar.isEmpty {
            navBar[0].isHidden = true
        }*/
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        //self.navigationController?.navigationBar.layer.zPosition = -1000
        //self.navigationController?.navigationBar.frame = .zero
        
        print(self.navigationController?.description)
        print(self.navigationController?.navigationBar.description)
        
        self.navigationController!.setNavigationBarHidden(true, animated: false)
        
        print("IS NAVIGATION BAR HIDDEN: \(self.navigationController?.isNavigationBarHidden)")
        
        /*for subview in self.navigationController!.view.subviews {
            print(subview.description)
        }*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("IS NAVIGATION BAR HIDDEN: \(self.navigationController?.isNavigationBarHidden)")
        
        print(self.navigationController?.description)
        print(self.navigationController?.navigationBar.description)
        
        let offsetY = -(tableView.contentOffset.y)
        
        print("OFFSET Y AFTER APPEARING: \(offsetY)")
        
        self.navigationController!.setNavigationBarHidden(true, animated: false)
        
        scrollViewDidScroll(tableView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    /*override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let navBar = findViewInViewHierarchy(withRootView: UIApplication.shared.windows.first!.rootViewController!.view, destinationType: "UINavigationBar")
        
        if !navBar.isEmpty {
            navBar[0].isHidden = false
        }
    }*/
    
    /*override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.layer.zPosition = -1000
        self.navigationController?.navigationBar.frame = .zero
        //self.navigationController?.navigationBar.isHidden = true
        //navigationController?.navigationBar.isTranslucent = false
        
        if let navigationSubview = UIApplication.shared.windows.first!.rootViewController!.view.subviews.first(where: {
            String(describing: type(of: $0)) == "UINavigationBar"
        }) {
            (navigationSubview as! UINavigationBar).isHidden = true
        }
        
        super.viewDidAppear(animated)
    }*/
    
    func addTitle() {
        let blurEffect = UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light)
        blurView = UIVisualEffectView(effect: blurEffect)
        //blurView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44 + 30 + tableView.safeAreaInsets.top)
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
        smallScoreLabel.textColor = .label
        smallScoreLabel.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        smallScoreLabel.layer.masksToBounds = true
        smallScoreLabel.layer.cornerRadius = 5
        
        //let nsText = "OmerFlameslkdfjghsdfglkjhsdfglkjhsdfglkjhsdfg" as NSString?
        //let text = "OmerFlame"
        
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
        
        //largeLabel.sizeToFit()
        
        //largeLabel.frame.size.width = bigLabelSize!.width
        
        smallLabel.text = profileData.username
        smallLabel.font = .systemFont(ofSize: 18, weight: .bold)
        smallLabel.textColor = .label
        smallLabel.adjustsFontSizeToFitWidth = true
        smallLabel.minimumScaleFactor = 0.1
        smallLabel.allowsDefaultTighteningForTruncation = true
        smallLabel.numberOfLines = 1
        
        //smallLabel.sizeToFit()
        
        largeLabel.translatesAutoresizingMaskIntoConstraints = false
        smallLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerTitle = UIStackView(frame: CGRect(x: 0, y: 0, width: largeLabel.frame.size.width + 5 + scoreLabel.intrinsicContentSize.width, height: max(largeLabel.frame.size.height, scoreLabel.intrinsicContentSize.height)))
        
        headerTitle.axis = .horizontal
        headerTitle.alignment = .center
        headerTitle.distribution = .equalCentering
        
        //largeLabel.setContentHuggingPriority(.required, for: .horizontal)
        //largeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
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
        //tableView.tableHeaderView!.addSubview(blurView)
        tableView.tableHeaderView!.addSubview(blurView)
        //navigationController?.view.bringSubviewToFront(blurView)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        //blurView.topAnchor.constraint(equalTo: view.topAnchor, constant: -tableView.safeAreaInsets.top).isActive = true
        //blurView.heightAnchor.constraint(equalTo: tableView.tableHeaderView!.heightAnchor).isActive = true
        
        //blurViewHeight = blurView.heightAnchor.constraint(equalTo: (tableView.tableHeaderView! as! SecondaryStretchyTableHeaderView).imageContainer.heightAnchor)
        //blurViewHeight.isActive = true
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.heightAnchor.constraint(equalTo: tableView.tableHeaderView!.heightAnchor).isActive = true
        
        blurView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
        
        largeLabel.translatesAutoresizingMaskIntoConstraints = false
        smallLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.leadingAnchor.constraint(equalTo: largeLabel.trailingAnchor, constant: 5).isActive = true
        
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
        
        print("EXPECTED LARGE LABEL HEIGHT: \(bigLabelSize.height)")
        print("LARGE LABEL HEIGHT:          \(largeLabel.frame.size.height)")
        
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
        
        //blurView.invalidateIntrinsicContentSize()

        //view.bringSubviewToFront(smallHeaderTitle)
        //view.bringSubviewToFront(segmentedControl)
    }
    
    /*override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurView.layer.zPosition = 1000
        //tableView.tableHeaderView!.layer.zPosition = -1000
    }*/
    
    @objc func selectionChanged(_ sender: UISegmentedControl) {
        print("Selection changed to \(secondaryProfilePages[sender.selectedSegmentIndex])")
        //tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
        //self.profile.rants = []
        //self.profile.upvoted = []
        //self.profile.comments = []
        //self.profile.favorites = []
        //self.supplementalImages = []
        
        //self.tableView.reloadData()
        //self.tableView.beginInfiniteScroll(true)
        //performFetch(nil)
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        temporaryIndex = segmentedControl.selectedSegmentIndex
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.profile.rants = []
            self.profile.upvoted = []
            self.profile.comments = []
            self.profile.favorites = []
            self.supplementalImages = []
            
            self.tableView.reloadData()
            //self.tableView.beginInfiniteScroll(true)
            self.performFetch(nil)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            (blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1].backgroundColor = .white
            ((blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1] as! UILabel).textColor = .black
        } else {
            (blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1].backgroundColor = .black
            ((blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1] as! UILabel).textColor = .white
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
                
                print(count) // I had to engage with the count variable before actually needing it in order to initialize the start and end variables. I know, stupid.
                
                //let (start, end) = (count, result!.profile.content.content.rants.count + count)
                
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
                
                //self.currentPage += 1
                
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
        /*do {
            self.content += try APIRequest().getProfileFromID(self.userID, userContentType: .rants, skip: 0)!.profile.content.content.rants
        } catch let error {
            print(error.localizedDescription)
            self.content += []
        }*/
        
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

class TestTableControler: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = SecondaryStretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 450))
        
        (tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).imageView.image = UIImage(named: "background_image")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.layer.zPosition = -1000
        self.navigationController?.navigationBar.frame = .zero
    }
}

struct TestTableView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return TestTableControler()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct TertiaryProfileScrollSwiftUI: UIViewControllerRepresentable {
    let userID: Int
    let profileData: Profile
    let image: UIImage?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return TertiaryProfileScroll(userID: self.userID, profileData: self.profileData, image: self.image)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

/*final class ProfileViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UITableViewController
    var profileData: Profile
    var userID: Int
    var image: UIImage?
    @ObservedObject var profile = profileViewData()
    
    var didGetRidOfNavigationBar = false
    
    class Vars {
        var parent: ProfileViewController
        
        init(_ parent: ProfileViewController) {
            self.parent = parent
        }
        
        var supplementalImages = [UIImage?]()
        
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
    }
    
    var MutableVars: Vars?
    
    init(profileData: Profile, userID: Int, image: UIImage?) {
        self.profileData = profileData
        self.userID = userID
        self.image = image
    }
    
    let profileTableController = UITableViewController(style: .plain)
    
    func makeUIViewController(context: Context) -> UITableViewController {
        self.MutableVars = Vars(self)
        
        profileTableController.tableView.contentInsetAdjustmentBehavior = .never
        profileTableController.navigationController?.isNavigationBarHidden = true
        
        
        if useAutosizingCells && profileTableController.tableView.responds(to: #selector(getter: UIView.layoutMargins)) {
            profileTableController.tableView.estimatedRowHeight = 150
            profileTableController.tableView.rowHeight = UITableView.automaticDimension
        }
        
        let headerView = SecondaryStretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 482))
        
        headerView.containerView.backgroundColor = UIColor(hex: profileData.avatar.b)!
        headerView.imageContainer.backgroundColor = UIColor(hex: profileData.avatar.b)!
        headerView.imageView.backgroundColor = UIColor(hex: profileData.avatar.b)!
        //let image = UIImage(named: "background_image")
        
        //UIGraphicsBeginImageContextWithOptions(CGSize(width: 350, height: 350), false, 4)
        //image!.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 350, height: 350)))
        
        //UIGraphicsBeginImageContextWithOptions(CGSize(width: 388, height: 388), false, 3.6082474226804123)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 382, height: 382), false, CGFloat(image!.size.height / 382))
        image!.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 382, height: 382)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        profileTableController.tableView.allowsSelection = false
        
        headerView.imageView.image = newImage
        
        profileTableController.tableView.tableHeaderView = headerView
        
        addTitle()
        
        profileTableController.tableView.delegate = context.coordinator
        profileTableController.tableView.dataSource = context.coordinator
        
        context.coordinator.scrollViewDidScroll(profileTableController.tableView)
        
        MutableVars!.blurView.contentView.isUserInteractionEnabled = true
        
        profileTableController.tableView.register(HostingCell<RantInFeedView>.self, forCellReuseIdentifier: "RantInFeedCell")
        profileTableController.tableView.register(HostingCell<Comment>.self, forCellReuseIdentifier: "CommentCell")
        
        profileTableController.tableView.infiniteScrollIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        profileTableController.tableView.infiniteScrollIndicatorMargin = 40
        profileTableController.tableView.infiniteScrollTriggerOffset = 500
        
        self.performFetch(nil)
        
        profileTableController.tableView.addInfiniteScroll { tableView -> Void in
            
            //let count = self.profile.rants.count
            //let (start, end) = (0, count)
            //let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
            
            //self.currentPage += 1
            
            //self.tableView.beginUpdates()
            //self.tableView.insertRows(at: indexPaths, with: .automatic)
            //self.tableView.endUpdates()
            
            //tableView.finishInfiniteScroll()
            //tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            
            //self.isDoneLoading = true
            
            self.performFetch {
                tableView.finishInfiniteScroll()
                
                if self.profile.rants.count == 30 {
                    tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                }
            }
        }
        
        return profileTableController
    }
    
    func makeCoordinator() -> (Coordinator) {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            guard parent.MutableVars!.segmentedControl != nil else {
                return parent.profile.rants.count
            }
           
            if parent.MutableVars!.segmentedControl.selectedSegmentIndex == 0 {
                return parent.profile.rants.count
            } else if parent.MutableVars!.segmentedControl.selectedSegmentIndex == 1 {
                return parent.profile.upvoted.count
            } else if parent.MutableVars!.segmentedControl.selectedSegmentIndex == 2 {
                return parent.profile.comments.count
            } else {
                return parent.profile.favorites.count
            }
        }
        
        /*func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fuckThis")
            
            cell?.textLabel?.text = "fuck"
            
            return cell!
        }*/
        
        var parent: ProfileViewController
        
        init(_ parent: ProfileViewController) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            /*for subview in UIApplication.shared.windows.first!.rootViewController!.view.subviews {
                print(String(describing: type(of: subview)))
            }*/
            
            guard parent.profileTableController.tableView.tableHeaderView != nil && parent.MutableVars!.headerTitle != nil else { return }
            
            let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
            
            let headerView = parent.profileTableController.tableView.tableHeaderView as! SecondaryStretchyTableHeaderView
            let headerGeometry = parent.geometry(view: headerView, scrollView: scrollView)
            
            let titleGeometry = parent.geometry(view: parent.MutableVars!.headerTitle, scrollView: scrollView)
            
            (parent.profileTableController.tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).containerView
                .alpha = CGFloat(sqrt(headerGeometry.largeTitleWeight))
            (parent.profileTableController.tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).imageContainer.alpha = CGFloat(sqrt(headerGeometry.largeTitleWeight))
            
            let largeTitleOpacity = (max(titleGeometry.largeTitleWeight, 0.5) - 0.5) * 2
            let tinyTitleOpacity = 1 - min(titleGeometry.largeTitleWeight, 0.5) * 2
            
            parent.MutableVars!.headerTitle.alpha = CGFloat(sqrt(largeTitleOpacity))
            
            parent.MutableVars!.blurView.contentView.subviews[1].alpha = CGFloat(sqrt(tinyTitleOpacity))
            
            if let vfxSubview = parent.MutableVars!.blurView.subviews.first(where: {
                String(describing: type(of: $0)) == "_UIVisualEffectSubview"
            }) {
                //vfxSubview.backgroundColor = UIColor.systemBackground.withAlphaComponent(map(CGFloat(1 - sqrt(titleGeometry.largeTitleWeight)), 0.0, 1.0, 0.0, 0.7))
                vfxSubview.backgroundColor = UIColor.systemBackground.withAlphaComponent(0)
            }
            
            if let vfxBackdrop = parent.MutableVars!.blurView.subviews.first(where: {
                String(describing: type(of: $0)) == "_UIVisualEffectBackdropView"
            }) {
                //vfxBackdrop.alpha = CGFloat(1 - sqrt(titleGeometry.largeTitleWeight))
                vfxBackdrop.alpha = CGFloat(1 - sqrt(titleGeometry.largeTitleWeight))
            }
            
            var blurFrame = parent.MutableVars!.blurView.frame
            var titleFrame = parent.MutableVars!.headerTitle.frame
            
            print("LAST MIN-Y: \(blurFrame.origin.y)")
            print("BLUR OFFSET: \(titleGeometry.blurOffset)")
            
            blurFrame.origin.y = max(parent.MutableVars!.originalBlurRect.minY, parent.MutableVars!.originalBlurRect.minY + titleGeometry.blurOffset)
            //titleFrame.origin.y = originalTitleRect.minY + 364
            titleFrame.origin.y = parent.MutableVars!.originalTitleRect.minY + 396
            
            parent.MutableVars!.blurView.frame = blurFrame
            parent.MutableVars!.headerTitle.frame = titleFrame
            
            //print("NEW MIN-Y: \(blurView.frame.origin.y)")
            
            headerView.scrollViewDidScroll(scrollView: scrollView)
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
        
        func listViewsInViewHierarchy(withRootView view: UIView) {
            let subviews = view.subviews
            
            if subviews.count == 0 {
                return
            }
            
            for subview in subviews {
                print(subview.description)
                
                listViewsInViewHierarchy(withRootView: subview)
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let navBar = findViewInViewHierarchy(withRootView: UIApplication.shared.windows.first!.rootViewController!.view, destinationType: "UINavigationBar")
            
            if !navBar.isEmpty {
                print(navBar[0].description)
                
                navBar[0].isHidden = true
                //parent.profileTableController.view.sendSubviewToBack(navBar[0])
                print(navBar[0].parentViewController!.description)
                
                //navBar[0].parentViewController.setNavigationBarHidden(true, animated: false)
            } else {
                print("NAVIGATION BAR NOT FOUND")
            }
            
            //listViewsInViewHierarchy(withRootView: UIApplication.shared.windows.first!.rootViewController!.view)
            
            switch parent.MutableVars!.segmentedControl.selectedSegmentIndex {
            case 0:
                let cell = parent.profileTableController.tableView.dequeueReusableCell(withIdentifier: "RantInFeedCell", for: indexPath) as! HostingCell<RantInFeedView>
                cell.set(rootView: RantInFeedView(rantContents: parent.$profile.rants[indexPath.row], uiImage: parent.MutableVars!.supplementalImages[indexPath.row]), parentController: parent.profileTableController)
                return cell
                
            case 1:
                let cell = parent.profileTableController.tableView.dequeueReusableCell(withIdentifier: "RantInFeedCell", for: indexPath) as! HostingCell<RantInFeedView>
                cell.set(rootView: RantInFeedView(rantContents: parent.$profile.upvoted[indexPath.row], uiImage: parent.MutableVars!.supplementalImages[indexPath.row]), parentController: parent.profileTableController)
                return cell
                
            case 2:
                let cell = parent.profileTableController.tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! HostingCell<Comment>
                cell.set(rootView: Comment(highlightColor: Color(UIColor(hex: parent.profile.comments[indexPath.row].user_avatar.b)!), commentContents: parent.profile.comments[indexPath.row]), parentController: parent.profileTableController)
                return cell
                
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RantInFeedCell", for: indexPath) as! HostingCell<RantInFeedView>
                cell.set(rootView: RantInFeedView(rantContents: parent.$profile.favorites[indexPath.row], uiImage: parent.MutableVars!.supplementalImages[indexPath.row]), parentController: parent.profileTableController)
                return cell
                
            default:
                fatalError("Internal inconsistency, UISegmentedControl's selected segment index is out of bounds")
            }
        }
    }
    
    func addTitle() {
        let blurEffect = UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light)
        MutableVars!.blurView = UIVisualEffectView(effect: blurEffect)
        //blurView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44 + 30 + tableView.safeAreaInsets.top)
        MutableVars!.blurView.frame = CGRect(x: 0, y: profileTableController.view.safeAreaInsets.top, width: UIScreen.main.bounds.size.width, height: 44 + 32)
        
        MutableVars!.segmentedControl = UISegmentedControl(items: secondaryProfilePages)
        MutableVars!.segmentedControl.selectedSegmentIndex = 0
        
        MutableVars!.segmentedControl.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 32, height: 32)
        
        UISegmentedControl.appearance().backgroundColor = .systemBackground
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(hex: profileData.avatar.b)!
        
        //segmentedControl.addTarget(self, action: #selector(selectionChanged(_:)), for: .valueChanged)
        MutableVars!.segmentedControl.addTarget(self, action: #selector(selectionChanged(_:)), for: .valueChanged)
        
        let scoreSize = "+\(String(profileData.score))".boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat.greatestFiniteMagnitude), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)], context: nil).size
        MutableVars!.scoreLabel = PaddingLabel(withInsets: 2.5, 2.5, 5, 5)
        MutableVars!.scoreLabel.text = "+\(String(profileData.score))"
        MutableVars!.scoreLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        MutableVars!.scoreLabel.textColor = .black
        MutableVars!.scoreLabel.backgroundColor = .white
        MutableVars!.scoreLabel.layer.masksToBounds = true
        MutableVars!.scoreLabel.layer.cornerRadius = 5
        
        let smallScoreLabel = PaddingLabel(withInsets: 2.5, 2.5, 5, 5)
        smallScoreLabel.text = "+\(String(profileData.score))"
        smallScoreLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        smallScoreLabel.textColor = .label
        smallScoreLabel.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        smallScoreLabel.layer.masksToBounds = true
        smallScoreLabel.layer.cornerRadius = 5
        
        //let nsText = "OmerFlameslkdfjghsdfglkjhsdfglkjhsdfglkjhsdfg" as NSString?
        //let text = "OmerFlame"
        
        var largeLabelHeight = UIFont.systemFont(ofSize: 34, weight: .black).lineHeight
        var smallLabelHeight = UIFont.systemFont(ofSize: 18, weight: .bold).lineHeight
        
        print("FONT HEIGHT: \(largeLabelHeight.rounded(.up))")
        
        let bigLabelSize = profileData.username.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 32 - MutableVars!.scoreLabel.intrinsicContentSize.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .black)], context: nil).size
        
        let smallLabelSize = profileData.username.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 32 - MutableVars!.scoreLabel.intrinsicContentSize.width, height: CGFloat.greatestFiniteMagnitude), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)], context: nil).size
        
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
        
        //largeLabel.sizeToFit()
        
        //largeLabel.frame.size.width = bigLabelSize!.width
        
        smallLabel.text = profileData.username
        smallLabel.font = .systemFont(ofSize: 18, weight: .bold)
        smallLabel.textColor = .label
        smallLabel.adjustsFontSizeToFitWidth = true
        smallLabel.minimumScaleFactor = 0.1
        smallLabel.allowsDefaultTighteningForTruncation = true
        smallLabel.numberOfLines = 1
        
        //smallLabel.sizeToFit()
        
        largeLabel.translatesAutoresizingMaskIntoConstraints = false
        smallLabel.translatesAutoresizingMaskIntoConstraints = false
        
        MutableVars!.headerTitle = UIStackView(frame: CGRect(x: 0, y: 0, width: largeLabel.frame.size.width + 5 + MutableVars!.scoreLabel.intrinsicContentSize.width, height: max(largeLabel.frame.size.height, MutableVars!.scoreLabel.intrinsicContentSize.height)))
        
        MutableVars!.headerTitle.axis = .horizontal
        MutableVars!.headerTitle.alignment = .center
        MutableVars!.headerTitle.distribution = .equalCentering
        
        //largeLabel.setContentHuggingPriority(.required, for: .horizontal)
        //largeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        MutableVars!.headerTitle.addArrangedSubview(largeLabel)
        MutableVars!.headerTitle.addArrangedSubview(MutableVars!.scoreLabel)
        
        let smallHeaderTitle = UIStackView(frame: CGRect(x: 0, y: 0, width: smallLabel.frame.size.width + 5 + smallScoreLabel.intrinsicContentSize.width, height: max(smallLabel.frame.size.height, smallScoreLabel.intrinsicContentSize.height)))
        
        smallHeaderTitle.axis = .horizontal
        smallHeaderTitle.alignment = .center
        smallHeaderTitle.distribution = .equalCentering
        
        smallHeaderTitle.addArrangedSubview(smallLabel)
        smallHeaderTitle.addArrangedSubview(smallScoreLabel)
        
        MutableVars!.blurView.contentView.addSubview(MutableVars!.headerTitle)
        MutableVars!.blurView.contentView.addSubview(smallHeaderTitle)
        MutableVars!.blurView.contentView.addSubview(MutableVars!.segmentedControl)
        //tableView.tableHeaderView!.addSubview(blurView)
        profileTableController.tableView.tableHeaderView!.addSubview(MutableVars!.blurView)
        //navigationController?.view.bringSubviewToFront(blurView)
        
        MutableVars!.blurView.translatesAutoresizingMaskIntoConstraints = false
        //blurView.topAnchor.constraint(equalTo: view.topAnchor, constant: -tableView.safeAreaInsets.top).isActive = true
        //blurView.heightAnchor.constraint(equalTo: tableView.tableHeaderView!.heightAnchor).isActive = true
        
        //blurViewHeight = blurView.heightAnchor.constraint(equalTo: (tableView.tableHeaderView! as! SecondaryStretchyTableHeaderView).imageContainer.heightAnchor)
        //blurViewHeight.isActive = true
        MutableVars!.blurView.topAnchor.constraint(equalTo: profileTableController.view.topAnchor).isActive = true
        MutableVars!.blurView.heightAnchor.constraint(equalTo: profileTableController.tableView.tableHeaderView!.heightAnchor).isActive = true
        
        MutableVars!.blurView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
        
        largeLabel.translatesAutoresizingMaskIntoConstraints = false
        smallLabel.translatesAutoresizingMaskIntoConstraints = false
        
        MutableVars!.scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        MutableVars!.scoreLabel.leadingAnchor.constraint(equalTo: largeLabel.trailingAnchor, constant: 5).isActive = true
        
        smallHeaderTitle.translatesAutoresizingMaskIntoConstraints = false
        smallHeaderTitle.insetsLayoutMarginsFromSafeArea = false
        
        smallScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        smallScoreLabel.leadingAnchor.constraint(equalTo: smallLabel.trailingAnchor, constant: 5).isActive = true
        smallScoreLabel.bottomAnchor.constraint(equalTo: smallLabel.bottomAnchor).isActive = true
        
        smallHeaderTitle.centerXAnchor.constraint(equalTo: MutableVars!.blurView.contentView.centerXAnchor).isActive = true
        smallHeaderTitle.heightAnchor.constraint(equalToConstant: max(smallLabel.frame.size.height, smallScoreLabel.intrinsicContentSize.height)).isActive = true
        smallHeaderTitle.widthAnchor.constraint(equalToConstant: smallLabel.frame.size.width + 5 + smallScoreLabel.intrinsicContentSize.width).isActive = true
        smallHeaderTitle.bottomAnchor.constraint(equalTo: MutableVars!.segmentedControl.topAnchor, constant: -8).isActive = true
        
        MutableVars!.headerTitle.translatesAutoresizingMaskIntoConstraints = false
        
        MutableVars!.headerTitle.bottomAnchor.constraint(equalTo: MutableVars!.segmentedControl.topAnchor, constant: -8).isActive = true
        MutableVars!.headerTitle.widthAnchor.constraint(equalToConstant: largeLabel.frame.size.width + 5 + MutableVars!.scoreLabel.intrinsicContentSize.width).isActive = true
        
        print("EXPECTED LARGE LABEL HEIGHT: \(bigLabelSize.height)")
        print("LARGE LABEL HEIGHT:          \(largeLabel.frame.size.height)")
        
        MutableVars!.headerTitle.heightAnchor.constraint(equalToConstant: max(largeLabel.frame.size.height, MutableVars!.scoreLabel.intrinsicContentSize.height)).isActive = true
        
        largeLabel.leadingAnchor.constraint(equalTo: MutableVars!.blurView.contentView.leadingAnchor, constant: 16).isActive = true
        
        MutableVars!.originalBlurRect = MutableVars!.blurView.frame
        MutableVars!.originalTitleRect = MutableVars!.headerTitle.frame
        
        MutableVars!.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        MutableVars!.segmentedControl.bottomAnchor.constraint(equalTo: MutableVars!.blurView.contentView.bottomAnchor, constant: -8).isActive = true
        MutableVars!.segmentedControl.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 32).isActive = true
        MutableVars!.segmentedControl.heightAnchor.constraint(equalToConstant: 32).isActive = true
        MutableVars!.segmentedControl.leadingAnchor.constraint(equalTo: MutableVars!.blurView.contentView.leadingAnchor, constant: 16).isActive = true
        
        if let v = profileTableController.tableView.tableHeaderView as? SecondaryStretchyTableHeaderView {
            v.segControl = MutableVars!.segmentedControl
        }
        
        MutableVars!.headerTitle.updateConstraints()
        
        //blurView.invalidateIntrinsicContentSize()

        //view.bringSubviewToFront(smallHeaderTitle)
        //view.bringSubviewToFront(segmentedControl)
    }
    
    
    
    /*func selectionChanged(_ sender: UISegmentedControl) {
        print("Selection changed to \(secondaryProfilePages[sender.selectedSegmentIndex])")
        profileTableController.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        profile.rants = []
        profile.upvoted = []
        profile.comments = []
        profile.favorites = []
        MutableVars!.supplementalImages = []
        
        profileTableController.tableView.reloadData()
        
        profileTableController.tableView.beginInfiniteScroll(true)
        //performFetch(nil)
    }*/
    
    /*override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            (blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1].backgroundColor = .white
            ((blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1] as! UILabel).textColor = .black
        } else {
            (blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1].backgroundColor = .black
            ((blurView.contentView.subviews[1] as! UIStackView).arrangedSubviews[1] as! UILabel).textColor = .white
        }
    }*/
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
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
                    if self.MutableVars!.segmentedControl.selectedSegmentIndex == 0 {
                        rantSequence = result!.profile.content.content.rants.enumerated()
                        
                        start = self.profile.rants.count
                        end = result!.profile.content.content.rants.count + start
                        
                        return self.profile.rants.count
                    } else if self.MutableVars!.segmentedControl.selectedSegmentIndex == 1 {
                        rantSequence = result!.profile.content.content.upvoted.enumerated()
                        
                        start = self.profile.upvoted.count
                        end = result!.profile.content.content.upvoted.count + start
                        
                        return self.profile.upvoted.count
                    } else if self.MutableVars!.segmentedControl.selectedSegmentIndex == 2 {
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
                
                print(count) // I had to engage with the count variable before actually needing it in order to initialize the start and end variables. I know, stupid.
                
                //let (start, end) = (count, result!.profile.content.content.rants.count + count)
                
                let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                
                if self.MutableVars!.segmentedControl.selectedSegmentIndex == 0 {
                    self.profile.rants.append(contentsOf: result!.profile.content.content.rants)
                } else if self.MutableVars!.segmentedControl.selectedSegmentIndex == 1 {
                    self.profile.upvoted.append(contentsOf: result!.profile.content.content.upvoted)
                } else if self.MutableVars!.segmentedControl.selectedSegmentIndex == 2 {
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
                            
                            self.MutableVars!.supplementalImages.append(newImage)
                        } else {
                            self.MutableVars!.supplementalImages.append(nil)
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
                            
                            self.MutableVars!.supplementalImages.append(newImage)
                        } else {
                            self.MutableVars!.supplementalImages.append(nil)
                        }
                    }
                }
                
                //self.currentPage += 1
                
                self.profileTableController.tableView.beginUpdates()
                self.profileTableController.tableView.insertRows(at: indexPaths, with: .automatic)
                self.profileTableController.tableView.endUpdates()
                
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
        profileTableController.present(alert, animated: true, completion: nil)
    }
    
    func getRants(completion: @escaping ((ProfileResponse?) -> Void)) {
        /*do {
            self.content += try APIRequest().getProfileFromID(self.userID, userContentType: .rants, skip: 0)!.profile.content.content.rants
        } catch let error {
            print(error.localizedDescription)
            self.content += []
        }*/
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(500)) {
            var skipCounter = 0
            
            var contentType: ProfileContentTypes {
                if self.MutableVars!.segmentedControl.selectedSegmentIndex == 0 {
                    skipCounter = self.profile.rants.count
                    return .rants
                } else if self.MutableVars!.segmentedControl.selectedSegmentIndex == 1 {
                    skipCounter = self.profile.upvoted.count
                    return .upvoted
                } else if self.MutableVars!.segmentedControl.selectedSegmentIndex == 2 {
                    skipCounter = self.profile.comments.count
                    return .comments
                } else {
                    skipCounter = self.profile.favorites.count
                    return .favorite
                }
            }
            
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
    
    @objc func selectionChanged(_ sender: UISegmentedControl) {
        print("Selection changed to \(secondaryProfilePages[sender.selectedSegmentIndex])")
        profileTableController.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        profile.rants = []
        profile.upvoted = []
        profile.comments = []
        profile.favorites = []
        MutableVars!.supplementalImages = []
        
        profileTableController.tableView.reloadData()
        
        //parent.profileTableController.tableView.beginInfiniteScroll(true)
        //performFetch(nil)
    }
    
    func updateUIViewController(_ uiViewController: UITableViewController, context: Context) {
        
    }
}

extension ProfileViewController {
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
        
        let hasScrolledToMinHeight = -minY >= 450 - 44 - safeArea.top

        let headerHeight = hasScrolledUp ?
            (profileTableController.tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).containerView.frame.size.height + minY + 32 : (profileTableController.tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).containerView.frame.size.height + 32

        let elementsHeight = (profileTableController.tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).frame.size.height + minY

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
            headerOffset = -minY - 450 + 44 + safeArea.top
            blurOffset = -minY - 450 + 44 + safeArea.top - 32
            elementsOffset = headerOffset / 2 - minY / 2
            largeTitleWeight = 0
        } else {
            headerOffset = 0
            blurOffset = 0
            elementsOffset = -minY / 2
            let difference = 450 - 44 - safeArea.top + minY
            largeTitleWeight = difference <= 44 + 1 ? Double(difference / (44 + 1)) : 1
        }
        
        return HeaderGeometry(width: (profileTableController.tableView.tableHeaderView as! SecondaryStretchyTableHeaderView).frame.size.width, headerHeight: headerHeight, elementsHeight: elementsHeight, headerOffset: headerOffset, blurOffset: blurOffset, elementsOffset: elementsOffset, largeTitleWeight: largeTitleWeight)
    }
}*/

public func map(_ x: CGFloat, _ inMin: CGFloat, _ inMax: CGFloat, _ outMin: CGFloat, _ outMax: CGFloat) -> CGFloat {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

