//
//  FileCell.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/12/20.
//

import UIKit

class FileCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: FileCell.self)
    
    var thumbnailImageView: UIImageView?
    var nameLabel: UILabel?
    
    var layoutConstraints: [NSLayoutConstraint]
    
    public override init(frame: CGRect) {
        layoutConstraints = []
        
        super.init(frame: .infinite)
        
        self.contentMode = .left
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
        
        thumbnailImageView?.layer.cornerCurve = .continuous
        thumbnailImageView?.layer.cornerRadius = 15
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
                    width: file.size!.width / 2,
                    height: file.size!.height / 2)
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

