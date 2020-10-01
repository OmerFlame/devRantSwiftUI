//
//  RandomAccessCollection+Extension.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/15/20.
//

import Foundation

extension RandomAccessCollection {
    func split(size: Int) -> [SubSequence] {
        precondition(size > 0, "Split size should be greater than 0.")
        var idx = startIndex
        var splits = [SubSequence]()
        splits.reserveCapacity(count / size)
        while idx < endIndex {
            let advanced = Swift.min(index(idx, offsetBy: size), endIndex)
            splits.append(self[idx..<advanced])
            idx = advanced
        }
        return splits
    }
}
