//
//  Constants.swift
//  Gemini
//
//  Created by Benjamin Yi on 7/1/18.
//  Copyright © 2018 Benjamin Yi. All rights reserved.
//

import Foundation

struct tileTag {
    var val: Int = 0
    var column:   Int { get { return ((val - 1001) % 16) + 1 } }
    var row:      Int { get { return ((val - 1001) / 16) + 1 } }
    var leading:  Int { get { return (((val - 1001) / 16) * 16) + 1001 } }
    var trailing: Int { get { return (((val - 1001) / 16) * 16) + 1016 } }
    var top:      Int { get { return ((val - 1001) % 16) + 1001 } }
    var bottom:   Int { get { return ((val - 1001) % 16) + 1129 } }
    init(v: Int) {
        val = v
    }
}
