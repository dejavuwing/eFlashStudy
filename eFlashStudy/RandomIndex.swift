//
//  RandomIndex.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 3. 29..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation

class RandomIndex {

    /// Return Random Int
    static func getIndex(maxNum: UInt32) -> Int {
        let randomNum: UInt32 = arc4random_uniform(maxNum)
        return Int(randomNum)
    }
}
