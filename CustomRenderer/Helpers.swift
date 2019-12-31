//
//  Helper.swift
//  CustomRenderer
//
//  Created by Maddy Adams on 12/14/19.
//  Copyright © 2019 Maddy Adams. All rights reserved.
//

import Foundation

class ReferenceHolder<T>: Sequence {
    typealias Element = T
    
    private var ts = [T]()
    
    func append(_ t: T) {
        ts.append(t)
    }
    
    func makeIterator() -> IndexingIterator<[T]> {
        return ts.makeIterator()
    }
}
