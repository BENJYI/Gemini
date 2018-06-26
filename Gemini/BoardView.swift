//
//  BoardView.swift
//  Gemini
//
//  Created by Benjamin Yi on 6/26/18.
//  Copyright © 2018 Benjamin Yi. All rights reserved.
//

import UIKit

class BoardView: UIView {
    var tileSet: TileSet?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tileWidth: CGFloat = frame.size.width / 16
        let tileHeight: CGFloat = frame.size.width / 9
        let tileDimensions = CGPoint.init(x: tileWidth, y: tileHeight)
        tileSet = TileSet.init(dimensions: tileDimensions)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
