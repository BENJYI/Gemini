//
//  ShiftingView.swift
//  Gemini
//
//  Created by Benjamin Yi on 6/30/18.
//  Copyright © 2018 Benjamin Yi. All rights reserved.
//

import UIKit

class ShiftingView: UIScrollView {
    var direction: String = ""
    var vectorDirection: Int = 0
    var minLimit: CGFloat = 0.0
    var maxLimit: CGFloat = 0.0
    var shiftingTiles: [TileView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func isHorizontal() -> Bool {
        if direction == "left" || direction == "right" {
            return true
        } else {
            return false
        }
    }
    
    func isVertical() -> Bool {
        if direction == "up" || direction == "down" {
            return true
        } else {
            return false
        }
    }
    
    func setPanLimits(with emptyTiles: Int, withDimesions tileDimensions: CGPoint) {
        let length: CGFloat = isHorizontal() ? tileDimensions.x : tileDimensions.y
        minLimit = vectorDirection < 0 ? CGFloat(emptyTiles) * length : 0.0
        maxLimit = vectorDirection > 0 ? CGFloat(emptyTiles) * length : 0.0
    }
    
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        // Offset on an axis is the inverse of a pan translation
        //   - A negative offset indicates a movement down or to the right
        //   - A positive offset indicates a movement up or to the left
        var offset = isHorizontal() ? contentOffset.x : contentOffset.y
        if offset > 0 {
            if minLimit == 0 {
                offset = 0
            } else if offset > minLimit {
                offset = minLimit
            }
        } else {
            if maxLimit == 0 {
                offset = 0
            } else if offset < (-1)*maxLimit {
                offset = (-1)*maxLimit
            }
        }
        let newOffset: CGPoint = isHorizontal() ? CGPoint.init(x: offset, y: 0) : CGPoint.init(x: 0, y: offset)
        super.setContentOffset(newOffset, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
