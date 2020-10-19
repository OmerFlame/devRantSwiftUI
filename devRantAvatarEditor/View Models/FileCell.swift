//
//  FileCell.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/12/20.
//

import UIKit
import SwiftUI

class FileCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: FileCell.self)
    
    var thumbnailImageView: UIImageView?
    var nameLabel: UILabel?
    
    var layoutConstraints: [NSLayoutConstraint]
    
    public override init(frame: CGRect) {
        layoutConstraints = []
        
        super.init(frame: .infinite)
        
        self.contentMode = .center
        self.isOpaque = false
        self.clipsToBounds = true
        self.autoresizesSubviews = true
        self.clearsContextBeforeDrawing = true
        self.isMultipleTouchEnabled = true
        self.isUserInteractionEnabled = true
        //self.sizeToFit()
        
        thumbnailImageView = UIImageView(image: UIImage(systemName: "doc"))
        thumbnailImageView?.tintColor = .label
        thumbnailImageView?.isOpaque = true
        
        thumbnailImageView?.contentMode = .scaleAspectFit
        thumbnailImageView?.clearsContextBeforeDrawing = true
        thumbnailImageView?.clipsToBounds = true
        thumbnailImageView?.autoresizesSubviews = true
        thumbnailImageView?.insetsLayoutMarginsFromSafeArea = true
        thumbnailImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        thumbnailImageView?.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        thumbnailImageView?.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        
        contentView.addSubview(thumbnailImageView!)
        
        //thumbnailImageView?.layer.cornerCurve = .continuous
        //thumbnailImageView?.layer.cornerRadius = 15
        //thumbnailImageView?.layer.borderColor = UIColor.systemBlue.cgColor
        //thumbnailImageView?.layer.borderWidth = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func update(with file: File) {
        nameLabel?.text = file.name
        
        file.generateThumbnail { [weak self] image in
            DispatchQueue.main.async {
                self?.thumbnailImageView!.image = image
                
                self?.thumbnailImageView?.frame.size = CGSize(
                    width: file.size!.width,
                    height: file.size!.height)
            }
        }
        
        print(thumbnailImageView!.frame.minX)
        print(thumbnailImageView!.frame.minY)
    }
    
    func updateConstraints(constraintArray: [NSLayoutConstraint]) {
        for constraint in constraintArray {
            constraint.isActive = true
        }
    }
}



struct TertiaryFileCell: UIViewRepresentable {
    @State var file: File
    @State var imageView = UIImageView()
    
    init(file: File) {
        self._file = .init(initialValue: file)
        self.update(with: file)
    }
    
    func makeUIView(context: Context) -> some UIView {
        imageView.tintColor = .label
        imageView.isOpaque = true
        
        imageView.contentMode = .scaleAspectFit
        imageView.clearsContextBeforeDrawing = true
        imageView.clipsToBounds = true
        imageView.autoresizesSubviews = true
        imageView.insetsLayoutMarginsFromSafeArea = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func update(with file: File) {
        self.file = file
        
        let resizeMultiplier = self.getImageResizeMultiplier(imageWidth: self.file.size!.width, imageHeight: self.file.size!.height, multiplier: 1)
        
        let finalWidth = self.file.size!.width / resizeMultiplier
        let finalHeight = self.file.size!.height / resizeMultiplier
        
        let finalSize = CGSize(width: finalWidth, height: finalHeight)
        
        print("FINAL WIDTH: \(finalWidth)")
        print("FINAL HEIGHT: \(finalHeight)")
        
        file.generateThumbnail(thumbnailSize: finalSize) { image in
            DispatchQueue.main.async {
                print("GENERATED IMAGE WIDTH: \(image.size.width)")
                print("GENERATED IMAGE HEIGHT: \(image.size.height)")
                
                self.imageView.image = image
                self.imageView.frame.size = CGSize(width: finalWidth, height: finalHeight)
                
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
}
