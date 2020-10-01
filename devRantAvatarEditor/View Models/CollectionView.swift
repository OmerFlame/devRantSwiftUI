//
//  CollectionView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/15/20.
//

import UIKit
import SwiftUI

struct CollectionViewRepresentable: UIViewRepresentable {
    var highlightColor: Color
    @State var comments: [CommentModel?]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(comments: self.comments, highlightColor: self.highlightColor)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        var comments: [CommentModel?]
        var highlightColor: Color
        
        init(comments: [CommentModel?], highlightColor: Color) {
            self.comments = comments
            self.highlightColor = highlightColor
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return comments.count
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GenericCell
            cell.commentData = self.comments[indexPath.item]
            cell.customView?.rootView = AnyView(Comment(highlightColor: self.highlightColor, commentContents: self.comments[indexPath.item]!))
            cell.highlightColor = self.highlightColor
            
            return cell
        }
    }
    
    func makeUIView(context: Context) -> some UIView {
        let layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            let width = UIScreen.main.bounds.size.width
            layout.estimatedItemSize = CGSize(width: width, height: 10)
            return layout
        }()
        
        layout.scrollDirection = .vertical
        let cvs = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cvs.dataSource = context.coordinator
        cvs.delegate = context.coordinator
        cvs.register(GenericCell.self, forCellWithReuseIdentifier: "cell")
        cvs.backgroundColor = .systemBackground
        
        return cvs
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

public class GenericCell: UICollectionViewCell {
    //public var textView = Text("")
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    
    var highlightColor: Color!
    var commentData: CommentModel!
    var customView: UIHostingController<AnyView>?
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        
        customView = UIHostingController(rootView: AnyView(Text("")))
        customView?.view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(customView!.view)
        customView!.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        //customView!.view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        //customView!.view.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
