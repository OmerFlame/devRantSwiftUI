//
//  AvatarEditor.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI
import QuickLook
import Combine

struct MainScreen: View {
    @State var isBottomSheetShown = false
    @State var apiRequest: APIRequest
    
    @State var shouldShowSettings = false
    @State var shouldShowLogin = false
    @State var shouldShowLoadingRing = true
    
    @State var shouldShowError = false
    @State var shouldLoadContinuously = false
    @State var shouldRenderLoadingRectangle = false
    
    @State var shouldFetchMore = false
    
    //@ObservedObject var rantFeed = RantFeedObservable()
    
    @State var isSheet = true
    
    @State var test = URL(string: "")
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    /*private func getFeed() {
        do {
            self.rantFeed = try self.apiRequest.getRantFeed()
            
            print("IS RANT FEED EMPTY: \(self.rantFeed == nil)")
        } catch {
            DispatchQueue.main.async {
                self.shouldShowError.toggle()
            }
        }
    }*/
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationView {
                    InfiniteScrollRepresentable()
                        //.listStyle(GroupedListStyle())
                        .navigationBarTitle(Text("Home"))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Menu(content: {
                                    Button(action: {
                                        self.shouldShowSettings.toggle()
                                    }, label: {
                                        HStack {
                                            Text("Settings")
                                            Image(systemName: "gearshape.fill")
                                        }
                                    })
                                
                                    Button(action: {
                                        self.shouldShowLogin.toggle()
                                    }, label: {
                                        HStack {
                                            Text("Log Out")
                                            Image(systemName: "lock.fill")
                                        }
                                    })
                                }, label: { Image(systemName: "ellipsis.circle.fill").font(.system(size: 25)) }
                                )
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Test") {
                                    //self.test = Bundle.main.url(forResource: "pngTest", withExtension: "png")
                                    
                                    //let containerController = UINavigationController(rootViewController: UIViewController())
                                    //containerController.modalPresentationStyle = .overFullScreen
                                    
                                    //containerController.didMove(toParent: self.viewController)
                                    //self.viewController?.addChild(containerController)
                                    //containerController.view.frame = (self.viewController?.view.frame)!
                                    //self.viewController?.view.addSubview(containerController.view)
                                    //containerController.didMove(toParent: self.viewController)
                                    
                                    //self.viewController?.present(containerController, animated: true)
                                    
                                    let previewController = previewTestController()
                                    previewController.modalPresentationStyle = .overCurrentContext
                                    previewController.didMove(toParent: self.viewController)
                                    //previewController.dataSource = previewControllerDataSource()
                                    self.viewController?.present(previewController, animated: true)
                                    //containerController.present(previewController, animated: true)
                                }
                            }
                        }
                        /*.background(DocumentPreview($test, // no matter where it is, because no content
                                                     url: Bundle.main.url(forResource: "pngTest", withExtension: "png")!))*/
                        .sheet(isPresented: $shouldShowLogin, content: {
                            LoginScreen(showVar: $shouldShowLogin, apiRequest: self.apiRequest).presentation(isSheet: $isSheet)
                        })
                        
                        .quickLookPreview($test)
                        //.padding(.top)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
    
    private struct OffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

/*final class TableViewController: UITableViewController {
    var rantFeed: RantFeedModel!
    
    let progressView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.startAnimating()
        view.addSubview(progressView)
        
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.tableView.isHidden = true
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        //progressView.topAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        
        progressView.center.y = UIScreen.main.bounds.size.height / 2
        progressView.startAnimating()
        
        rantFeed = RantFeedModel(delegate: self)
        
        /*DispatchQueue.global(qos: .userInteractive).async {
            self.rantFeed.rantFeed += APIRequest().getRantFeed().rants ?? []
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                progressView.stopAnimating()
                self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
            }
        }*/
        
        rantFeed.loadMoreContent()
        
        tableView.register(HostingCell.self, forCellReuseIdentifier: "HostingCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rantFeed.rants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostingCell", for: indexPath) as! HostingCell
        
        if isLoadingCell(for: indexPath) {
            cell.configure(with: .none)
        } else {
            cell.configure(with: rantFeed.rant(at: indexPath.row))
        }
        
        return cell
    }
    
    /*override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        //let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        //let pathToLastRow = IndexPath(row: lastRowIndex, section: 0)
        
        
        var newIndexPaths = [IndexPath]()
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            DispatchQueue.global(qos: .userInitiated).sync {
                let newRants = APIRequest().getRantFeed().rants ?? []
                //self.rantFeed.rantFeed += newRants
                
                for row in (self.rantFeed.rantFeed.count..<(self.rantFeed.rantFeed.count + newRants.count)) {
                    newIndexPaths.append(IndexPath(row: row, section: 0))
                }
                
                self.rantFeed.rantFeed += newRants
                
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    //self.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                    self.tableView.insertRows(at: newIndexPaths, with: .automatic)
                    self.tableView.endUpdates()
                }
            }
        }
    }*/
    
    /*func stoppedScrolling(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            DispatchQueue.global(qos: .userInitiated).sync {
                self.rantFeed.rantFeed += APIRequest().getRantFeed().rants ?? []
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("CHILD DISMISSED")
        self.tableView.reloadData()
    }
}

extension TableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            rantFeed.loadMoreContent()
        }
    }
}

extension TableViewController: RantFeedModelDelegate {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            progressView.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    func onFetchFailed(with reason: String) {
        progressView.stopAnimating()
        
        let title = "Warning"
        let alert = UIAlertController(title: title, message: reason, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        guard presentedViewController == nil else { return }
        
        present(alert, animated: true)
    }
}

private extension TableViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= rantFeed.rants.count
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
      let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
      let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
      return Array(indexPathsIntersection)
    }
}

struct TableRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return TableViewController(style: .plain)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}*/

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    typealias Value = Bool
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

extension UIScrollView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.isDirectionalLockEnabled = true
        
        if scrollView.contentOffset.x > 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        //MainScreen(apiRequest: APIRequest())
        MainScreen(apiRequest: APIRequest())
    }
}
