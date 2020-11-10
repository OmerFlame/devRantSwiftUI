//
//  InfiniteScroll.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/25/20.
//

import UIKit
import SwiftUI

let useAutosizingCells = true

class InfiniteScroll: UITableViewController {
    fileprivate var currentPage = 0
    //fileprivate var numPages = 0
    @ObservedObject var rantFeed = rantFeedData()
    var supplementalImages = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView = IntrinsicTableView(frame: .zero)
        
        if useAutosizingCells && tableView.responds(to: #selector(getter: UIView.layoutMargins)) {
            tableView.estimatedRowHeight = 150
            tableView.rowHeight = UITableView.automaticDimension
        }
        
        tableView.infiniteScrollIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        
        tableView.infiniteScrollIndicatorMargin = 40
        tableView.infiniteScrollTriggerOffset = 500
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        tableView.register(HostingCell<RantInFeedView>.self, forCellReuseIdentifier: "HostingCell")
        
        tableView.addInfiniteScroll { tableView -> Void in
            self.performFetch {
                tableView.finishInfiniteScroll()
                
                if self.rantFeed.rantFeed.count == 20 || self.refreshControl!.isRefreshing {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    self.refreshControl!.endRefreshing()
                }
            }
        }
        
        tableView.beginInfiniteScroll(true)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        tableView.addSubview(self.refreshControl!)
    }
    
    fileprivate func performFetch(_ completionHandler: (() -> Void)?) {
        fetchData { result in
            defer { completionHandler?() }
            
            switch result.success {
            case true:
                let count = self.rantFeed.rantFeed.count
                let (start, end) = (count, result.rants!.count + count)
                let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                
                self.rantFeed.rantFeed.append(contentsOf: result.rants!)
                
                for (idx, rant) in result.rants!.enumerated() {
                    if rant.attached_image != nil {
                        let completionSemaphore = DispatchSemaphore(value: 0)
                        
                        var image = UIImage()
                        
                        URLSession.shared.dataTask(with: URL(string: (result.rants![idx].attached_image?.url!)!)!) { data, _, _ in
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
    
    fileprivate func showAlertWithError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.performFetch(nil) }))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < UIScreen.main.bounds.width && imageHeight / CGFloat(multiplier) < UIScreen.main.bounds.height {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}

extension InfiniteScroll {
    @objc func handleRefresh() {
        rantFeed.rantFeed = []
        supplementalImages = []
        
        tableView.reloadData()
        
        tableView.beginInfiniteScroll(true)
    }
}

class IntrinsicTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

extension InfiniteScroll {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rantFeed.rantFeed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rant = $rantFeed.rantFeed[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostingCell", for: indexPath) as! HostingCell<RantInFeedView>
        
        cell.set(rootView: RantInFeedView(rantContents: rant, parentTableView: tableView, uiImage: supplementalImages[indexPath.row]), parentController: self)
        
        return cell
    }
}

extension InfiniteScroll {
    fileprivate func fetchData(handler: @escaping ((RantFeed) -> Void)) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds((rantFeed.rantFeed.count == 0 ? 0 : 1))) {
            let data = APIRequest().getRantFeed(skip: self.rantFeed.rantFeed.count)
            
            DispatchQueue.main.async {
                handler(data)
            }
        }
    }
}

struct InfiniteScrollRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return InfiniteScroll()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

// MARK: - Profile Scroll View

/*class ProfileInfiniteScrollView: UITableViewController {
    @State var viewSelection: ProfilePages = .rants
    @State var isComplete = false
    @State var shouldShowError = false
    
    var userID: Int
    var userInfo: Profile? = nil
    
    var skipCounter = 0
    
    var heightConstraint = NSLayoutConstraint()
    
    var image: UIImage?
    @State var imageOpacity: Double = 1
    
    init(userID: Int) {
        self.userID = userID
        self.image = UIImage()
        super.init(style: .plain)
        
        self.view.frame = CGRect(x: 0, y: 450, width: view.bounds.width, height: .greatestFiniteMagnitude)
        
        UISegmentedControl.appearance().backgroundColor = .systemBackground
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @ObservedObject var content = rantFeedData()
    fileprivate var currentPage = 0
    var supplementalImages = [UIImage?]()
    
    override func viewDidLoad() {
        if useAutosizingCells && tableView.responds(to: #selector(getter: UIView.layoutMargins)) {
            tableView.estimatedRowHeight = 88
            tableView.rowHeight = UITableView.automaticDimension
        }
        
        heightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height)
        
        heightConstraint.isActive = true
        
        tableView.infiniteScrollIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        tableView.infiniteScrollIndicatorMargin = 40
        tableView.infiniteScrollTriggerOffset = 500
        
        tableView.isScrollEnabled = false
        
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
        
        tableView.contentOffset = CGPoint(x: 0, y: 450)
        
        //let activityIndicator = UIActivityIndicatorView()
        //activityIndicator.hidesWhenStopped = true
        //activityIndicator.startAnimating()
        
        /*let completionSemaphore = DispatchSemaphore(value: 0)
        
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
        }*/
        
        //view.insetsLayoutMarginsFromSafeArea = false
        
        //completionSemaphore.wait()
        //let imageHeader = Header(imageOpacity: 1.0, image: self.image!, userAvatar: self.userInfo!.avatar)
        
        /*let hostingHeader = UIHostingController(rootView: HeaderScrollView(title: self.userInfo!.username,
                                                                           upvotes: self.userInfo!.score,
                                                                           pageSelection: self.$viewSelection,
                                                                           opacity: imageHeader.imageOpacity,
                                                                           headerHeight: 450,
                                                                           scrollUpBehavior: .parallax,
                                                                           scrollDownBehavior: .offset,
                                                                           header: imageHeader,
                                                                           content: nil).headerOnly).view*/
        
        /*let hostingHeader = UIHostingController(rootView: HeaderView(title: self.userInfo!.username,
                                                                     upvotes: self.userInfo!.score,
                                                                     opacity: imageHeader.imageOpacity,
                                                                     headerHeight: 450,
                                                                     scrollUpBehavior: .parallax,
                                                                     scrollDownBehavior: .offset,
                                                                     header: imageHeader)).view*/
        
        //tableView.tableHeaderView = hostingHeader
        
        
        //hostingHeader!.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 450)
        
        //tableView.infiniteScrollIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        //tableView.infiniteScrollIndicatorMargin = 40
        //tableView.infiniteScrollTriggerOffset = 500
        
        //tableView.separatorStyle = .none
        
        //tableView.register(HostingCell<RantInFeedView>.self, forCellReuseIdentifier: "HostingCell")
        
        /*tableView.addInfiniteScroll { tableView -> Void in
            self.performFetch {
                tableView.finishInfiniteScroll()
                
                if self.content.rantFeed.count == 30 {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    //self.refreshControl!.endRefreshing()
                }
            }
        }
        
        tableView.beginInfiniteScroll(true)*/
        
        //hostingHeader?.clipsToBounds = true
        
        //self.tableView.tableHeaderView = hostingHeader
        
        //tableView.tableHeaderView?.isUserInteractionEnabled = true
        //tableView.contentInset = UIEdgeInsets(top: 450, left: 0, bottom: 0, right: 0)
        //tableView.contentOffset = CGPoint(x: 0, y: 450)
        //tableView.tableHeaderView?.insetsLayoutMarginsFromSafeArea = false
        
        //view.insetsLayoutMarginsFromSafeArea = false
    }
    
    override func updateViewConstraints() {
        heightConstraint.constant = tableView.contentSize.height
        super.updateViewConstraints()
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
    
    fileprivate func showAlertWithError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.performFetch(nil) }))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
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
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
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
    
    /*override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let imageHeader = Header(imageOpacity: 1.0, image: self.image!, userAvatar: self.userInfo!.avatar)
        
        return UIHostingController(rootView: HeaderView(title: self.userInfo!.username,
                                                        upvotes: self.userInfo!.score,
                                                        opacity: imageHeader.imageOpacity,
                                                        headerHeight: 450,
                                                        scrollUpBehavior: .parallax,
                                                        scrollDownBehavior: .offset,
                                                        header: imageHeader)).view
    }*/
}

struct ProfileInfiniteScrollViewRepresentable: UIViewControllerRepresentable {
    let userID: Int
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return ProfileInfiniteScrollView(userID: self.userID)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
*/
