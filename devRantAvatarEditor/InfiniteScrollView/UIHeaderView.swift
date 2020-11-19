//
//  UIHeaderView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/28/20.
//

import UIKit
import Foundation

private let navigationBarHeight: CGFloat = 44

class UIHeaderView: UIView {
    var imageViewHeight = NSLayoutConstraint()
    var imageViewWidth = NSLayoutConstraint()
    
    var imageViewBottom = NSLayoutConstraint()
    
    var containerView: UIView!
    var imageView: UIImageView!
    
    var containerViewHeight = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        
        setViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "d55161")
        self.addSubview(containerView)
        
        imageView = UIImageView()
        
        imageView.clipsToBounds = true
        imageView.backgroundColor = .yellow
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
    }
    
    func setViewConstraints() {
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            self.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        //containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalToConstant: self.bounds.width).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeight.isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageViewBottom = imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        //imageViewBottom.isActive = true
        imageViewHeight = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        imageViewHeight.isActive = true
        imageViewWidth = imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor)
        imageViewWidth.isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let geometry = self.geometry(scrollView: scrollView)
        
        self.frame.size.height = geometry.headerHeight
        //let newFrame = self.frame.offsetBy(dx: 0, dy: geometry.headerOffset)
        //self.frame = newFrame
        containerView.clipsToBounds = true
        
        //containerViewHeight.constant = scrollView.contentInset.top
        //let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        //containerView.clipsToBounds = offsetY <= 0
        //imageViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
        //imageViewHeight.constant = max(offsetY + scrollView.contentInset.top - 100, scrollView.contentInset.top - 100)
        //imageViewWidth.constant = max(offsetY + scrollView.contentInset.top - 100, scrollView.contentInset.top - 100)
        //imageViewWidth.isActive = true
        
        
        
        //print(max(offsetY + scrollView.contentInset.top - 100, scrollView.contentInset.top - 100))
        
        /*var safeArea = self.safeAreaInsets
        
        let minY = self.frame.minY
        let hasScrolledUp = minY > 0
        let hasScrolledToMinHeight = -minY >= headerHeight - navigationBarHeight - safeArea.top

        let headerHeight = hasScrolledUp && self.scrollUpBehavior == .parallax ?
            geometry.size.height + minY + 38 : geometry.size.height + 38

        let elementsHeight = hasScrolledUp && self.scrollUpBehavior == .sticky ?
            geometry.size.height : geometry.size.height + minY

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
            headerOffset = -minY - self.headerHeight + navigationBarHeight + safeArea.top
            blurOffset = -minY - self.headerHeight + navigationBarHeight + safeArea.top
            elementsOffset = headerOffset / 2 - minY / 2
            largeTitleWeight = 0
        } else {
            headerOffset = self.scrollDownBehavior == .sticky ? -minY : 0
            blurOffset = 0
            elementsOffset = -minY / 2
            let difference = self.headerHeight - navigationBarHeight - safeArea.top + minY
            largeTitleWeight = difference <= navigationBarHeight + 1 ? Double(difference / (navigationBarHeight + 1)) : 1
        }*/
    }
}

extension UIHeaderView {
    struct HeaderGeometry {
        let width: CGFloat
        let headerHeight: CGFloat
        let elementsHeight: CGFloat
        let headerOffset: CGFloat
        let blurOffset: CGFloat
        let elementsOffset: CGFloat
        let largeTitleWeight: Double
    }
    
    func geometry(scrollView: UIScrollView) -> HeaderGeometry {
        let safeArea = scrollView.safeAreaInsets
        
        let minY = scrollView.frame.minY
        
        print("MIN Y: \(minY)")
        
        let hasScrolledUp = minY > 0
        
        print("HAS SCROLLED UP: \(hasScrolledUp)")
        
        let hasScrolledToMinHeight = -minY >= 450 - navigationBarHeight - safeArea.top
        
        print("HAS SCROLLED TO MIN HEIGHT: \(hasScrolledToMinHeight)")

        let headerHeight = hasScrolledUp ?
            containerView.frame.size.height + minY + 38 : containerView.frame.size.height + 38
        
        print("CURRENT HEADER HEIGHT: \(self.frame.size.height)")
        
        print("NEW HEADER HEIGHT: \(headerHeight)")

        let elementsHeight = self.frame.size.height + minY

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
            headerOffset = -minY - 450 + navigationBarHeight + safeArea.top
            blurOffset = -minY - 450 + navigationBarHeight + safeArea.top
            elementsOffset = headerOffset / 2 - minY / 2
            largeTitleWeight = 0
        } else {
            headerOffset = 0
            blurOffset = 0
            elementsOffset = -minY / 2
            let difference = 450 - navigationBarHeight - safeArea.top + minY
            largeTitleWeight = difference <= navigationBarHeight + 1 ? Double(difference / (navigationBarHeight + 1)) : 1
        }
        
        return HeaderGeometry(width: self.frame.size.width, headerHeight: headerHeight, elementsHeight: elementsHeight, headerOffset: headerOffset, blurOffset: blurOffset, elementsOffset: elementsOffset, largeTitleWeight: largeTitleWeight)
    }
}

class StretchyTableHeaderView: UIView {
    var imageViewHeight = NSLayoutConstraint()
    var imageViewWidth = NSLayoutConstraint()
    var imageViewBottom = NSLayoutConstraint()
    
    var containerView: UIView!
    var imageContainer: UIView!
    var imageView: UIImageView!
    
    var containerViewHeight = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hex: "d55161")
        
        createViews()
        
        setViewConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createViews() {
        // Container View
        containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "d55161")
        self.addSubview(containerView)
        
        // ImageView for background
        imageView = UIImageView()
        //imageView.frame.size.height = 350
        //imageView.frame.size.width = 350
        imageView.clipsToBounds = true
        imageView.backgroundColor = .yellow
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
    }
    
    func setViewConstraints() {
        // UIView Constraints
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            self.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        // Container View Constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        //containerView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeight.isActive = true
        
        // ImageView Constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageViewBottom = imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        //imageViewBottom.isActive = true
        imageViewHeight = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: -100)
        imageViewHeight.isActive = true
        imageViewWidth = imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -100)
        imageViewWidth.isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        containerViewHeight.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        containerView.clipsToBounds = offsetY <= 0
        //imageViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
        imageViewHeight.constant = max(offsetY + scrollView.contentInset.top - 100, scrollView.contentInset.top - 100)
        imageViewWidth.constant = max(offsetY + scrollView.contentInset.top - 100, scrollView.contentInset.top - 100)
    }
}

class SecondaryStretchyTableHeaderView: UIView {
    var imageContainerHeight = NSLayoutConstraint()
    var imageContainerBottom = NSLayoutConstraint()
    
    var imageViewHeight = NSLayoutConstraint()
    var imageViewBottom = NSLayoutConstraint()
    var imageViewTop = NSLayoutConstraint()
    
    
    var containerView: UIView!
    var imageContainer: UIView!
    var imageView: UIImageView!
    
    var largeTitleOpacity = Double()
    var tinyTitleOpacity = Double()
    
    var largeLabel: UILabel!
    var tinyLabel: UILabel!
    
    var containerViewHeight = NSLayoutConstraint()
    
    var stack: UIStackView!
    
    var title: StretchyHeaderTitle!
    
    weak var segControl: UISegmentedControl?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        
        setViewConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled,
              !isHidden,
              alpha >= 0.01,
              let sc = segControl
        else { return nil }
        
        let convertedPoint = sc.convert(point, from: self)
        if let v = sc.hitTest(convertedPoint, with: event) {
            return v
        }
        
        guard self.point(inside: point, with: event) else { return nil }
        
        return self
    }
    
    func createViews() {
        
        // Container View
        containerView = UIView()
        //containerView.backgroundColor = UIColor(hex: "d55161")
        self.addSubview(containerView)
        
        imageContainer = UIView()
        //imageContainer.backgroundColor = UIColor(hex: "d55161")
        //imageContainer.contentMode = .scaleAspectFill
        imageContainer.clipsToBounds = true
        containerView.addSubview(imageContainer)
        
        // ImageView for background
        imageView = UIImageView()
        //imageView.clipsToBounds = true
        //imageView.backgroundColor = UIColor(hex: "d55161")
        imageView.contentMode = .scaleAspectFill
        imageContainer.addSubview(imageView)
    }
    
    func setViewConstraints() {
        // UIView Constraints
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            self.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        // Container View Constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalTo: imageContainer.widthAnchor).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeight.isActive = true
        
        // ImageView Constraints
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainerBottom = imageContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        imageContainerBottom.isActive = true
        imageContainerHeight = imageContainer.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        imageContainerHeight.isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewBottom = imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: -50)
        //imageViewBottom = imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: -100)
        
        imageViewBottom.isActive = true
        
        imageViewTop = imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 50)
        //imageViewTop = imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 100)
        
        imageViewTop.isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor).isActive = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top) - 100
        
        containerViewHeight.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        
        containerView.clipsToBounds = offsetY <= 0
        imageContainerBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
        imageContainerHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
        imageContainer.clipsToBounds = offsetY <= 0
        
        
        imageViewBottom.constant = (offsetY >= 0 ? 0 : -offsetY / 2) - 50
        //imageViewBottom.constant = (offsetY >= 0 ? 0 : -offsetY / 2) - 100
        
        imageViewTop.constant = (offsetY >= 0 ? 0 : -offsetY / 2) + 50
        //imageViewTop.constant = (offsetY >= 0 ? 0 : -offsetY / 2) + 100
        
        //imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top) - 100
    }
}

class StretchyHeaderTitle: UIView {
    var title: String
    var upvotes: Int
    var height: CGFloat
    var largeTitle: Double
    
    var largeTitleOpacity = Double()
    var tinyTitleOpacity = Double()
    
    var largeLabel: UILabel!
    var tinyLabel: UILabel!
    var stackView: UIStackView!
    
    var stackViewRect: CGRect!
    
    init(title: String, upvotes: Int, height: CGFloat, largeTitle: Double, frame: CGRect) {
        self.title = title
        self.upvotes = upvotes
        self.height = height
        self.largeTitle = largeTitle
        
        self.largeTitleOpacity = (max(largeTitle, 0.5) - 0.5) * 2
        self.tinyTitleOpacity = 1 - min(largeTitle, 0.5) * 2
        
        super.init(frame: frame)
        
        createViews()
        
        //setViewConstraints()
    }
    
    func createViews() {
        let largeLabelSize = (title as NSString).boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 32, height: CGFloat.greatestFiniteMagnitude), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .black)], context: nil).size
        
        largeLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: largeLabelSize))
        largeLabel.text = title
        largeLabel.font = .systemFont(ofSize: 34, weight: .black)
        largeLabel.textColor = .white
        largeLabel.bounds = largeLabel.frame.insetBy(dx: 16, dy: 0)
        largeLabel.minimumScaleFactor = 0.2
        largeLabel.allowsDefaultTighteningForTruncation = true
        largeLabel.numberOfLines = 1
        largeLabel.adjustsFontSizeToFitWidth = true
        
        let scoreSize = ("+\(String(upvotes))" as NSString).boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat.greatestFiniteMagnitude), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)], context: nil).size
        
        let scoreLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: scoreSize))
        scoreLabel.text = "+\(String(self.upvotes))"
        //scoreLabel.bounds = scoreLabel.frame.insetBy(dx: 5, dy: 2.5)
        scoreLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        scoreLabel.textColor = .black
        
        let scoreRect = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: scoreSize.width + 10, height: scoreSize.height + 5)))
        scoreRect.layer.cornerRadius = 5
        scoreRect.backgroundColor = .white
        scoreRect.bounds = scoreRect.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0))
        
        scoreRect.addSubview(scoreLabel)
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreLabel.leadingAnchor.constraint(equalTo: scoreRect.leadingAnchor, constant: 5),
            scoreLabel.trailingAnchor.constraint(equalTo: scoreRect.trailingAnchor, constant: -5),
            scoreLabel.topAnchor.constraint(equalTo: scoreRect.topAnchor, constant: 2.5),
            scoreLabel.bottomAnchor.constraint(equalTo: scoreRect.bottomAnchor, constant: -2.5)
        ])
        
        stackView = UIStackView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: max(largeLabelSize.width, scoreRect.frame.size.width), height: max(largeLabelSize.height, scoreRect.frame.size.height))))
        stackView.alignment = .center
        stackView.axis = .horizontal
        
        stackViewRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: max(largeLabelSize.width, scoreRect.frame.size.width), height: max(largeLabelSize.height, scoreRect.frame.size.height)))
        
        stackView.addArrangedSubview(largeLabel)
        //stackView.addArrangedSubview(scoreRect)
        //stackView.bounds = stackView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
        
        stackView.alpha = CGFloat(sqrt(largeTitleOpacity))
        
        //stackView.sizeToFit()
        
        self.bounds = CGRect(x: 0, y: 0, width: stackView.frame.size.width, height: stackView.frame.size.height)
    }
    
    /*func setViewConstraints() {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            self.topAnchor.constraint(equalTo: stackView.topAnchor),
            self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }*/
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
