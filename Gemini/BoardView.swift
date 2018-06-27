//
//  BoardView.swift
//  Gemini
//
//  Created by Benjamin Yi on 6/26/18.
//  Copyright © 2018 Benjamin Yi. All rights reserved.
//

import UIKit

class BoardView: UIView, TileSetDelegate {
    var tileSet: TileSet?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let tileWidth: CGFloat = frame.size.width / 16
        let tileHeight: CGFloat = frame.size.height / 9
        let tileDimensions = CGPoint.init(x: tileWidth, y: tileHeight)
        if tileSet == nil {
            tileSet = TileSet.init(dimensions: tileDimensions)
            tileSet!.delegate = self
            layTiles()
        }
    }
    
    func reloadTiles() {
        setNeedsLayout()
    }
    
    func layTiles() {
        removeTiles()
        for tile in tileSet!.tiles {
            addSubview(tile)
        }
    }
    
    func removeTiles() {
        for tile in tileSet!.tiles {
            tile.removeFromSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("stop calling this")
        
        for tile in tileSet!.tiles {
            addSubview(tile)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
