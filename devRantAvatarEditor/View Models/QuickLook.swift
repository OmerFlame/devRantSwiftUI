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
    
    init(files: [File]) {
        //let completionSemaphore = DispatchSemaphore(value: 0)
        /*let tmpDirectory = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
        tmpDirectory.forEach { file in
            let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
            try! FileManager.default.removeItem(atPath: path)
        }*/
        
        //remoteURLs = urls
        self.files = files
        
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
        if imageWidth / CGFloat(multiplier) < UIScreen.main.bounds.width && imageHeight / CGFloat(multiplier) < UIScreen.main.bounds.size.height {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let quickLookViewController = QLPreviewController()
        quickLookViewController.dataSource = self
        quickLookViewController.delegate = self
        tappedCell = collectionView.cellForItem(at: indexPath) as? FileCell
        
        quickLookViewController.currentPreviewItemIndex = indexPath.row
        present(quickLookViewController, animated: false)
    }
}

// MARK: - QLPreviewControllerDataSource
extension UIPreviewView: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        files.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        files[index].previewItemURL as QLPreviewItem
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
    var images: [AttachedImage]
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let files = File.loadFiles(images: self.images)
        
        let previewView = UIPreviewView(files: files)
        
        return previewView
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct QLView: View {
    let attachedImage: AttachedImage
    
    var body: some View {
        let files = File.loadFiles(images: [self.attachedImage])
        let resizeMultiplier: CGFloat = getImageResizeMultiplier(imageWidth: files[0].size!.width, imageHeight: files[0].size!.height, multiplier: 1)
        let finalWidth = files[0].size!.width / resizeMultiplier
        let finalHeight = files[0].size!.height / resizeMultiplier
        
        UIPreviewViewRepresentable(images: [self.attachedImage])
            .frame(width: finalWidth, height: finalHeight)
            .background(Color(UIColor.systemBackground))
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < UIScreen.main.bounds.width && imageHeight / CGFloat(multiplier) < UIScreen.main.bounds.height {
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
        if imageWidth / CGFloat(multiplier) < UIScreen.main.bounds.width && imageHeight / CGFloat(multiplier) < UIScreen.main.bounds.height {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}
