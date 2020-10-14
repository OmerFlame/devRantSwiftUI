//
//  SecondaryFileCell.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/13/20.
//

import SwiftUI
import UIKit
import QuickLook

class SecondaryFileCell: UIView {
    static let reuseIdentifier = String(describing: SecondaryFileCell.self)
    var imageView: UIImageView?
    
    var file: File?
    
    let quickLookViewController = QLPreviewController()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentMode = .center
        self.isOpaque = false
        self.clipsToBounds = true
        self.autoresizesSubviews = true
        self.clearsContextBeforeDrawing = true
        self.isMultipleTouchEnabled = true
        self.isUserInteractionEnabled = true
        //self.sizeToFit()
        
        imageView = UIImageView(frame: frame)
        imageView!.image = UIImage(systemName: "doc")
        imageView!.tintColor = .label
        imageView!.isOpaque = true
        
        imageView!.contentMode = .scaleAspectFit
        imageView!.clearsContextBeforeDrawing = true
        imageView!.clipsToBounds = true
        imageView!.autoresizesSubviews = true
        imageView!.insetsLayoutMarginsFromSafeArea = true
        imageView!.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageView!)
        
        self.layer.cornerCurve = .continuous
        self.layer.cornerRadius = 15
        
        quickLookViewController.dataSource = self
        quickLookViewController.delegate = self
        quickLookViewController.currentPreviewItemIndex = 0
        
        //let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        //self.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with file: File) {
        self.file = file
        
        let resizeMultiplier = getImageResizeMultiplier(imageWidth: self.file!.size!.width, imageHeight: self.file!.size!.height, multiplier: 1)
        
        
        let finalWidth = self.file!.size!.width / resizeMultiplier
        let finalHeight = self.file!.size!.height / resizeMultiplier
        
        let finalSize = CGSize(width: finalWidth, height: finalHeight)
        
        print("FINAL WIDTH: \(finalWidth)")
        print("FINAL HEIGHT: \(finalHeight)")
        
        file.generateThumbnail(thumbnailSize: finalSize) { [weak self] image in
            DispatchQueue.main.async {
                print("GENERATED IMAGE WIDTH: \(image.size.width)")
                print("GENERATED IMAGE HEIGHT: \(image.size.height)")
                
                self?.imageView?.image = image
                
                self?.frame.size = finalSize
                
                //self?.thumbnailImageView?.heightAnchor.constraint(equalToConstant: height).isActive = true
                //self?.thumbnailImageView?.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
        }
        
        //print(thumbnailImageView!.frame.minX)
        //print(thumbnailImageView!.frame.minY)
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < UIScreen.main.bounds.width && imageHeight / CGFloat(multiplier) < UIScreen.main.bounds.size.height {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
    
    func updateConstraintsFromConstraintArray(constraintArray: [NSLayoutConstraint]) {
        for constraint in constraintArray {
            constraint.isActive = true
        }
        
        self.updateConstraints()
    }
    
    func getCurrentViewController() -> UIViewController? {

        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil

    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension SecondaryFileCell: QLPreviewControllerDataSource {
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.file!.previewItemURL as QLPreviewItem
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
}

extension SecondaryFileCell: QLPreviewControllerDelegate {
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        imageView
    }
}

struct SecondaryFileCellRepresentable: UIViewRepresentable {
    let attachedImage: AttachedImage
    
    @State var fileCell = SecondaryFileCell()
    
    @State var file = File()
    
    init(attachedImage: AttachedImage) {
        self.attachedImage = attachedImage
        self.file = File.loadFiles(images: [self.attachedImage])[0]
        
        print("BREAK HERE")
    }
    
    func makeUIView(context: Context) -> some UIView {
        let file = File.loadFiles(images: [self.attachedImage])[0]
        
        let resizeMultiplier = self.getImageResizeMultiplier(imageWidth: CGFloat(self.attachedImage.width!), imageHeight: CGFloat(self.attachedImage.height!), multiplier: 1)
        
        let cell = SecondaryFileCell(frame: CGRect(x: 0, y: 0, width: CGFloat(self.attachedImage.width!) / resizeMultiplier, height: CGFloat(self.attachedImage.height!) / resizeMultiplier))
        
        self.fileCell = cell
        
        self.fileCell.update(with: file)
        
        let layoutConstraints = [
            self.fileCell.trailingAnchor.constraint(equalTo: self.fileCell.imageView!.trailingAnchor),
            self.fileCell.leadingAnchor.constraint(equalTo: self.fileCell.imageView!.leadingAnchor),
            self.fileCell.topAnchor.constraint(equalTo: self.fileCell.imageView!.topAnchor),
            self.fileCell.bottomAnchor.constraint(equalTo: self.fileCell.imageView!.bottomAnchor),
            self.fileCell.imageView!.heightAnchor.constraint(equalToConstant: CGFloat(self.attachedImage.height!) / resizeMultiplier),
            self.fileCell.imageView!.widthAnchor.constraint(equalToConstant: CGFloat(self.attachedImage.width!) / resizeMultiplier)
        ]
        
        self.fileCell.updateConstraintsFromConstraintArray(constraintArray: layoutConstraints)
        
        return self.fileCell
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    private func getImageResizeMultiplier(imageWidth: CGFloat, imageHeight: CGFloat, multiplier: Int) -> CGFloat {
        if imageWidth / CGFloat(multiplier) < UIScreen.main.bounds.width && imageHeight / CGFloat(multiplier) < UIScreen.main.bounds.size.height {
            return CGFloat(multiplier)
        } else {
            return getImageResizeMultiplier(imageWidth: imageWidth, imageHeight: imageHeight, multiplier: multiplier + 2)
        }
    }
}
