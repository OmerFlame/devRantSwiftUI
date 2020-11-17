//
//  QuickLook.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/12/20.
//

import SwiftUI
import UIKit
import QuickLook

class UIPreviewView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    //var remoteURLs: [URL]
    var collectionView: UICollectionView?
    var vc: UIViewController
    
    init(files: [File], parentViewController: UIViewController) {
        //let completionSemaphore = DispatchSemaphore(value: 0)
        /*let tmpDirectory = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
        tmpDirectory.forEach { file in
            let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
            try! FileManager.default.removeItem(atPath: path)
        }*/
        
        //remoteURLs = urls
        self.files = files
        self.vc = parentViewController
        
        print(files)
        
        super.init(nibName: nil, bundle: nil)
        
        let view = UIView()
        view.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let resizeMultiplier: CGFloat = getImageResizeMultiplier(imageWidth: files[0].size!.width, imageHeight: files[0].size!.height, multiplier: 1)
        
        let finalWidth = files[0].size!.width / resizeMultiplier
        let finalHeight = files[0].size!.height / resizeMultiplier
        
        self.view.frame = CGRect(origin: self.view.frame.origin, size: CGSize(width: finalWidth, height: finalHeight))
        
        let view = UIView()
        view.backgroundColor = .systemBackground
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //layout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        //layout.itemSize = CGSize(width: 108, height: 128)
        //layout.itemSize = CGSize(width: 384, height: 306)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        collectionView?.register(FileCell.self, forCellWithReuseIdentifier: FileCell.reuseIdentifier)
        collectionView?.backgroundColor = .systemBackground
        collectionView?.contentMode = .left
        
        collectionView?.layer.cornerCurve = .continuous
        collectionView?.layer.cornerRadius = 15
        
        collectionView?.isScrollEnabled = false
        
        view.contentMode = .left
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        view.addSubview(collectionView ?? UICollectionView())
        
        view.resizeToFitSubviews()
        
        self.view = view
        
        //self.view.resizeToFitSubviews()
    }
    
    weak var tappedCell: FileCell?
    var files: [File]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FileCell.reuseIdentifier,
                for: indexPath) as? FileCell
        else {
            return UICollectionViewCell()
        }
        
        cell.update(with: files[indexPath.row])
        
        let width = files[indexPath.row].size?.width
        let height = files[indexPath.row].size?.height
        
        let resizeMultiplier: CGFloat = getImageResizeMultiplier(imageWidth: width!, imageHeight: height!, multiplier: 1)
        
        let layoutConstraints = [
            cell.contentView.trailingAnchor.constraint(equalTo: cell.thumbnailImageView!.trailingAnchor),
            cell.contentView.leadingAnchor.constraint(equalTo: cell.thumbnailImageView!.leadingAnchor),
            cell.contentView.topAnchor.constraint(equalTo: cell.thumbnailImageView!.topAnchor),
            cell.contentView.bottomAnchor.constraint(equalTo: cell.thumbnailImageView!.bottomAnchor),
            cell.thumbnailImageView!.heightAnchor.constraint(equalToConstant: files[indexPath.row].size!.height / CGFloat(resizeMultiplier)),
            cell.thumbnailImageView!.widthAnchor.constraint(equalToConstant: files[indexPath.row].size!.width / CGFloat(resizeMultiplier))
        ]
        
        cell.updateConstraints(constraintArray: layoutConstraints)
        
        collectionView.resizeToFitSubviews()
        return cell
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let quickLookViewController = QLPreviewController()
        quickLookViewController.modalPresentationStyle = .overFullScreen
        quickLookViewController.dataSource = self
        quickLookViewController.delegate = self
        tappedCell = collectionView.cellForItem(at: indexPath) as? FileCell
        
        quickLookViewController.currentPreviewItemIndex = indexPath.row
        vc.present(quickLookViewController, animated: true)
    }
}

// MARK: - QLPreviewControllerDataSource
extension UIPreviewView: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        files.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return files[index].previewItemURL as QLPreviewItem
    }
}

// MARK: - QLPreviewControllerDelegate
extension UIPreviewView: QLPreviewControllerDelegate {
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        return tappedCell?.thumbnailImageView
    }
    
    /*func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .updateContents
    }*/
    
    /*func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        guard let file = previewItem as? File else { return }
        DispatchQueue.main.async {
            self.tappedCell?.update(with: file)
        }
    }*/
}

extension UIView {
    func resizeToFitSubviews() {
        let subviewsRect = subviews.reduce(CGRect.zero) {
            $0.union($1.frame)
        }
        
        let fix = subviewsRect.origin
        subviews.forEach {
            $0.frame.offsetBy(dx: -fix.x, dy: -fix.y)
        }
        
        frame.offsetBy(dx: fix.x, dy: fix.y)
    }
}

struct UIPreviewViewRepresentable: UIViewControllerRepresentable {
    var files: [File]
    var parentViewController: UIViewController
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        
        let previewView = UIPreviewView(files: files, parentViewController: self.parentViewController)
        
        return previewView
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct QLView: View {
    let file: File
    let parentViewController: UIViewController
    
    var body: some View {
        //let files = File.loadFiles(images: [self.attachedImage])
        let resizeMultiplier: CGFloat = getImageResizeMultiplier(imageWidth: self.file.size!.width, imageHeight: self.file.size!.height, multiplier: 1)
        let finalWidth = self.file.size!.width / resizeMultiplier
        let finalHeight = self.file.size!.height / resizeMultiplier
        
        UIPreviewViewRepresentable(files: [self.file], parentViewController: self.parentViewController)
            .frame(width: finalWidth, height: finalHeight)
            .background(Color(UIColor.systemBackground))
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}

struct SecondaryQLView: View {
    let attachedImage: AttachedImage
    
    @State var url = URL(string: "")
    
    @State var pendingURL: URL
    
    //@State var fileCell = SecondaryFileCell()
    
    var body: some View {
        let file = File.loadFiles(images: [self.attachedImage])[0]
        //self.pendingURL = file.url
        let resizeMultiplier: CGFloat = getImageResizeMultiplier(imageWidth: CGFloat(self.attachedImage.width!), imageHeight: CGFloat(self.attachedImage.height!), multiplier: 1)
        let finalWidth = CGFloat(self.attachedImage.width!) / resizeMultiplier
        let finalHeight = CGFloat(self.attachedImage.height!) / resizeMultiplier
        
        ThumbnailImageView(url: self.pendingURL, size: CGSize(width: finalWidth, height: finalHeight))
            .foregroundColor(Color(UIColor.systemBackground))
            .fixedSize(horizontal: false, vertical: true)
            .scaledToFit()
            .frame(width: finalWidth,
                   height: finalHeight)
            .quickLookPreview($url)
            .onTapGesture {
                self.url = self.pendingURL
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .onAppear {
                print(self.pendingURL.relativePath)
            }
            //.scaledToFill()
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < 315 && imageHeight / CGFloat(multiplier) < 420 {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}

struct TertiaryQLView: View {
    //let attachedImage: AttachedImage
    var parentViewController: UIViewController
    @State var fileCell: TertiaryFileCell?
    @State var shouldPreview = false
    
    init(file: File, parentViewController: UIViewController) {
        self.parentViewController = parentViewController
        /*self.attachedImage = attachedImage
        
        let resizeMultiplier = self.getImageResizeMultiplier(imageWidth: CGFloat(self.attachedImage.width!), imageHeight: CGFloat(self.attachedImage.height!), multiplier: 1)
        
        let finalWidth = CGFloat(self.attachedImage.width!) / resizeMultiplier
        let finalHeight = CGFloat(self.attachedImage.height!) / resizeMultiplier
        
        let file = File.loadFile(image: self.attachedImage, size: CGSize(width: finalWidth, height: finalHeight))*/
        
        self._fileCell = .init(initialValue: TertiaryFileCell(file: file))
    }
    
    var body: some View {
        ZStack {
            self.fileCell
                .frame(width: self.fileCell?.file.size?.width, height: self.fileCell?.file.size?.height)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .onTapGesture {
                    self.shouldPreview.toggle()
                }
            
            if self.shouldPreview {
                withAnimation {
                    PreviewController(fileCell: self.fileCell!, parentViewController: self.parentViewController)
                        .onDisappear {
                            self.shouldPreview.toggle()
                        }
                }
            }
        }
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < UIScreen.main.bounds.width && imageHeight / CGFloat(multiplier) < UIScreen.main.bounds.size.height {
                return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}

class PreviewView: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    var fileCell: TertiaryFileCell
    var vc: UIViewController
    
    init(fileCell: TertiaryFileCell, parentViewController: UIViewController) {
        self.fileCell = fileCell
        self.vc = parentViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let previewController = QLPreviewController()
        previewController.modalPresentationStyle = .overFullScreen
        previewController.dataSource = self
        previewController.delegate = self
        previewController.currentPreviewItemIndex = 0
        
        vc.present(previewController, animated: true)
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        fileCell.file.url as QLPreviewItem
    }
    
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        fileCell.imageView
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
}

struct PreviewController: UIViewControllerRepresentable {
    let fileCell: TertiaryFileCell
    let parentViewController: UIViewController
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return PreviewView(fileCell: self.fileCell, parentViewController: self.parentViewController)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

protocol EmbeddedQLPreviewControllerDelegate: class {
    func embeddedQLPreviewControllerDidDismiss(_ viewController: EmbeddedQLPreviewController)
}

class EmbeddedQLPreviewController: UIViewController, QLPreviewControllerDelegate {
    weak var delegate: EmbeddedQLPreviewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.open(animated: animated)
    }
    
    private func open(animated: Bool) {
        let viewController = QLPreviewController()
        viewController.delegate = self
        self.present(viewController, animated: false)
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        self.dismiss(animated: false) {
            self.delegate?.embeddedQLPreviewControllerDidDismiss(self)
        }
    }
}

/*class QuickLookViewModel {
    var dummy: _DummyViewController!
    var vc: QLPreviewController?
}

public class _DummyViewController: UIViewController {}

struct EmbeddedQuickLook: UIViewControllerRepresentable {
    @Binding var showPreview: Bool
    @State private var viewModel = QuickLookViewModel()
    public var onDismiss: (() -> Void)?
    
    public init(showPreview: Binding<Bool>, onDismiss: (() -> Void)? = nil) {
        self._showPreview = showPreview
        self.onDismiss = onDismiss
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let dummy = _DummyViewController()
        viewModel.dummy = dummy
        return dummy
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    final class Coordinator: NSObject, QLPreviewControllerDelegate {
        var parent: EmbeddedQuickLook
        
        init(_ parent: EmbeddedQuickLook) {
            self.parent = parent
        }
        
        func previewControllerDidDismiss(_ controller: QLPreviewController) {
            parent.showPreview = false
            parent.onDismiss?()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard viewModel.dummy != nil else {
            return
        }
        
        let ableToPresent = viewModel.dummy.presentedViewController == nil || viewModel.dummy.presentedViewController?.isBeingDismissed == true
        
        let ableToDismiss = viewModel.vc != nil
        
        if showPreview && viewModel.vc == nil && ableToPresent {
            let previewVC = QLPreviewController()
            previewVC.delegate = context.coordinator
            viewModel.vc = previewVC
            viewModel.dummy.present(previewVC, animated: true)
        } else if !showPreview && ableToDismiss {
            viewModel.dummy.dismiss(animated: true)
            self.viewModel.vc = nil
        }
    }
}
*/

class FullScreenQuickLook: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let previewController = QLPreviewController()
        
        addChild(previewController)
        view.addSubview(previewController.view)
        
        previewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        previewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        previewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

/*struct PreviewControllerTest: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPresented: Bool
    
    @State var controller: UIDocumentInteractionController? = nil
    
    func makeUIViewController(context: Context) -> UINavigationController {
        self.controller = UIDocumentInteractionController(url: self.url)
        /*controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: context.coordinator, action: #selector(context.coordinator.dismiss)
        )*/
        
        let navigationController = UINavigationController(rootViewController: controller!)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}*/

struct PreviewTest: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: context.coordinator, action: #selector(context.coordinator.dismiss)
        )
        
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        let parent: PreviewTest
        
        init(parent: PreviewTest) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.url as NSURL
        }
        
        @objc func dismiss() {
            parent.isPresented = false
        }
        
    }
}

struct DocumentPreview: UIViewControllerRepresentable {
    private var isActive: Binding<Bool>
    private let viewController = UIViewController()
    private let docController: UIDocumentInteractionController

    init(_ isActive: Binding<Bool>, url: URL) {
        self.isActive = isActive
        self.docController = UIDocumentInteractionController(url: url)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPreview>) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DocumentPreview>) {
        if self.isActive.wrappedValue && docController.delegate == nil { // to not show twice
            docController.delegate = context.coordinator
            self.docController.presentPreview(animated: true)
        }
    }

    func makeCoordinator() -> Coordintor {
        return Coordintor(owner: self)
    }

    final class Coordintor: NSObject, UIDocumentInteractionControllerDelegate { // works as delegate
        let owner: DocumentPreview
        init(owner: DocumentPreview) {
            self.owner = owner
        }
        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            return owner.viewController
        }

        func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
            controller.delegate = nil // done, so unlink self
            owner.isActive.wrappedValue = false // notify external about done
        }
    }
}

// Demo of possible usage
struct DemoPDFPreview: View {
    @State private var showPreview = false // state activating preview

    var body: some View {
        VStack {
            Button("Show Preview") { self.showPreview = true }
                .background(DocumentPreview($showPreview, // no matter where it is, because no content
                            url: Bundle.main.url(forResource: "example", withExtension: "pdf")!))
        }
    }
}

struct DemoPDFPreview_Previews: PreviewProvider {
    static var previews: some View {
        DemoPDFPreview()
    }
}
