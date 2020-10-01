//
//  CollectionViewLayout.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/15/20.
//

import Foundation
import UIKit

enum CollectionViewLayout {
    case singleLine
    case flow
    case multiLine(numberOfLines: Int)
    
    func layout<Elements>(for elements: Elements, containerSize: CGSize, sizes: CollectionViewElementSize<Elements>) -> CollectionViewElementSize<Elements> {
        switch self {
        case .singleLine, .multiLine:
            return singleLineLayout(for: elements, containerSize: containerSize, sizes: sizes)
            
        case .flow:
            return flowLayout(for: elements, containerSize: containerSize, sizes: sizes)
        }
    }
    
    private func singleLineLayout<Elements>(for elements: Elements, containerSize: CGSize, sizes: CollectionViewElementSize<Elements>) -> CollectionViewElementSize<Elements> {
        
        var result: CollectionViewElementSize<Elements> = [:]
        var offset = CGSize.zero
        for element in elements {
            result[element.id] = offset
            let size = sizes[element.id] ?? CGSize.zero
            offset.width += size.width
        }
        return result
    }
    
    private func flowLayout<Elements>(for elements: Elements, containerSize: CGSize, sizes: CollectionViewElementSize<Elements>) -> CollectionViewElementSize<Elements> {
        
        var state = FlowLayout(containerSize: containerSize)
        var result: CollectionViewElementSize<Elements> = [:]
        for element in elements {
            let rect = state.add(element: sizes[element.id] ?? .zero)
            result[element.id] = CGSize(width: rect.origin.x, height: rect.origin.y)
        }
        return result
    }
    
    private struct FlowLayout {
        let spacing: UIOffset
        let containerSize: CGSize
        
        init(containerSize: CGSize, spacing: UIOffset = UIOffset(horizontal: 5, vertical: 5)) {
            self.spacing = spacing
            self.containerSize = containerSize
        }
        
        var current = CGPoint.zero
        var lineHeight = 0 as CGFloat
        
        mutating func add(element size: CGSize) -> CGRect {
            if current.x + size.width > containerSize.width {
                current.x = 0
                current.y += lineHeight + self.spacing.vertical
                lineHeight = 0
            }
            defer {
                lineHeight = max(lineHeight, size.height)
                current.x += size.width + self.spacing.horizontal
            }
            return CGRect(origin: current, size: size)
        }
    }
}
