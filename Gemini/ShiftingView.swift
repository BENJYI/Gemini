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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
