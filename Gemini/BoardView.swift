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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let tileWidth: CGFloat = frame.size.width / 16
        let tileHeight: CGFloat = frame.size.height / 9
        let tileDimensions = CGPoint.init(x: tileWidth, y: tileHeight)
        tileSet = TileSet.init(dimensions: tileDimensions)
        for tile in tileSet!.tiles {
            addSubview(tile)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
