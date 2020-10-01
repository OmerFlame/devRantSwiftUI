//
//  String+Extension.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/15/20.
//

import UIKit

extension String {
    func image(with font: UIFont = UIFont.systemFont(ofSize: 16.0)) -> UIImage {
        let string = NSString(string: "\(self)")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let size = string.size(withAttributes: attributes)
        
        return UIGraphicsImageRenderer(size: size).image { _ in
            string.draw(at: .zero, withAttributes: attributes)
        }
    }
    
    func images(with font: UIFont = UIFont.systemFont(ofSize: 16.0)) -> [UIImage] {
        return self.map { "\($0)".image() }
    }
}

extension String: Identifiable {
    public var id: String { self }
}
