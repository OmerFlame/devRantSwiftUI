//
//  ContentView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI
import Combine
import QuickLook

enum SheetTypes: Int {
    case settings
    case login
    case compose
}

struct ContentView: View {
    @State var shouldShowLogin = false
    @State var shouldShowEditor = false
    @State var userID = UserDefaults.standard.integer(forKey: "DRUserID")
    @State var tokenID = UserDefaults.standard.integer(forKey: "DRTokenID")
    @State var tokenKey = UserDefaults.standard.string(forKey: "DRTokenKey")
    
    @State var username = UserDefaults.standard.string(forKey: "DRUsername")
    @State var password = UserDefaults.standard.string(forKey: "DRPassword")
    
    @State var isSheet = true
    
    @State var apiRequest = APIRequest()
    
    @State var isBottomSheetShown = false
    
    @State var sheetPage: SheetTypes = .compose
    @State var showSheet = false
    
    @State var shouldShowLoadingRing = true
    
    @State var shouldShowError = false
    @State var shouldShowCompose = false
    @State var shouldLoadContinuously = false
    @State var shouldRenderLoadingRectangle = false
    
    @State var shouldFetchMore = false
    
    //@ObservedObject var rantFeed = RantFeedObservable()
    
    @State var test = URL(string: "")
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    var body: some View {
        VStack {
            /*if self.userID == 0 || self.tokenID == 0 || self.tokenKey == nil {
                EmptyView()
            } else if self.shouldShowEditor == true {
                AvatarEditor()
            }*/
            
            if self.shouldShowLogin {
                EmptyView()
            }
            
            if self.shouldShowEditor {
                //MainScreen(apiRequest: self.apiRequest)
                
                //.navigationViewStyle(StackNavigationViewStyle())
                NavigationView {
                    InfiniteScrollRepresentable()
                        .navigationBarTitle(Text("Home"))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Menu(content: {
                                    Button(action: {
                                        
                                    }, label: {
                                        HStack {
                                            Text("Settings")
                                            Image(systemName: "gearshape.fill")
                                        }
                                    })
                                
                                    Button(action: {
                                        self.sheetPage = SheetTypes.init(rawValue: 1)!
                                        //self.shouldShowLogin.toggle()
                                    }, label: {
                                        HStack {
                                            Text("Log Out")
                                            Image(systemName: "lock.fill")
                                        }
                                    }).sheet(isPresented: $shouldShowLogin, onDismiss: {
                                        if self.sheetPage == .login {
                                            self.shouldShowLogin = false
                                            self.shouldShowEditor = true
                                        }
                                    }) {
                                        LoginScreen(showVar: $showSheet, apiRequest: self.apiRequest).presentation(isSheet: $isSheet)
                                    }
                                }, label: { Image(systemName: "ellipsis.circle.fill").font(.system(size: 25)) }
                                )
                            }
                            
                            /*ToolbarItem(placement: .navigationBarTrailing) {
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
                                    previewController.modalPresentationStyle = .overFullScreen
                                    previewController.didMove(toParent: self.viewController)
                                    //previewController.dataSource = previewControllerDataSource()
                                    self.viewController?.present(previewController, animated: true)
                                    //containerController.present(previewController, animated: true)
                                }
                            }*/
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    self.shouldShowCompose = true
                                    //self.shouldShowSettings = false
                                    self.shouldShowLogin = false
                                    
                                    //self.showSheet.toggle()
                                    //print("pressed")
                                }, label: { Image(systemName: "square.and.pencil") })
                                .sheet(isPresented: $shouldShowCompose) {
                                    ComposeView(shouldShow: $shouldShowCompose, isComment: false, rantID: nil).presentation(isSheet: .constant(true))
                                }
                            }
                        }
                }
            }
            
            /*Group {
                if self.shouldShowLogin {
                    EmptyView()
                } else {
                    PreviewTester()
                }
            }*/
        }
        .onAppear {
            if self.userID == 0 || self.tokenID == 0 || self.tokenKey == nil || self.username == nil || self.password == nil {
                self.sheetPage = .login
                //self.showSheet.toggle()
            } else {
                self.shouldShowEditor.toggle()
            }
        }
        .onChange(of: self.sheetPage) { _ in
            self.showSheet.toggle()
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            if self.sheetPage == .login {
                self.shouldShowLogin = false
                self.shouldShowEditor = true
            }
        }) {
            if self.sheetPage == .login {
                LoginScreen(showVar: $showSheet, apiRequest: self.apiRequest).presentation(isSheet: .constant(true))
            } else if self.sheetPage == .compose {
                ComposeView(shouldShow: $showSheet, isComment: false, rantID: nil).presentation(isSheet: .constant(true))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class rantFeedData: ObservableObject {
    @Published var rantFeed = [RantInFeed]()
}

final class HostingCell<Content: View>: UITableViewCell {
    let hostingController = UIHostingController<Content?>(rootView: nil)
    public var height = CGFloat()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        hostingController.view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(rootView: Content, parentController: UIViewController, shouldLoadIntoController: Bool) {
        self.hostingController.rootView = rootView
        self.hostingController.view.invalidateIntrinsicContentSize()
        
        let requiresControllerMove = hostingController.parent != parentController
        if requiresControllerMove && shouldLoadIntoController {
            parentController.addChild(hostingController)
        }
        
        if !self.contentView.subviews.contains(hostingController.view) {
            self.contentView.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            hostingController.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            hostingController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            hostingController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        }
        
        layoutIfNeeded()
        
        self.contentView.frame.size.height = hostingController.view.intrinsicContentSize.height
        
        self.invalidateIntrinsicContentSize()
        self.contentView.invalidateIntrinsicContentSize()
        
        hostingController.view.layoutIfNeeded()
        
        if requiresControllerMove && shouldLoadIntoController {
            hostingController.didMove(toParent: parentController)
        }
        
        height = self.contentView.frame.size.height
    }
}

class ObservableArray<T>: ObservableObject {
    var cancellables = [AnyCancellable]()
    
    @Published var array: [T] = []
    
    init(array: [T]) {
        self.array = array
    }
    
    func observeChildrenChange<T: ObservableObject>() -> ObservableArray<T> {
        let array2 = array as! [T]
        array2.forEach({
            let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
            
            self.cancellables.append(c)
        })
        return self as! ObservableArray<T>
    }
}

struct ViewControllerHolder {
    weak var value: UIViewController?
    init(_ value: UIViewController?) {
        self.value = value
    }
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder { return ViewControllerHolder(UIApplication.shared.windows.first?.rootViewController) }
}

extension EnvironmentValues {
    var viewController: ViewControllerHolder {
        get { return self[ViewControllerKey.self] }
        set { self[ViewControllerKey.self] = newValue }
    }
}

class previewTestController: QLPreviewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    var originRect: CGRect
    var url: URL?
    
    init(rect: CGRect, url: URL?) {
        self.originRect = rect
        self.url = url
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        //return Bundle.main.url(forResource: "pngTest", withExtension: "png")! as QLPreviewItem
        return url! as QLPreviewItem
    }
    
    /*func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        self.originalView
    }*/
    
    func previewController(_ controller: QLPreviewController, frameFor item: QLPreviewItem, inSourceView view: AutoreleasingUnsafeMutablePointer<UIView?>) -> CGRect {
        originRect
    }
}
