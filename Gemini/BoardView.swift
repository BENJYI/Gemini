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
        
        let tileWidth: CGFloat = frame.size.width / 16
        let tileHeight: CGFloat = frame.size.height / 9
        let tileDimensions = CGPoint.init(x: tileWidth, y: tileHeight)
        backgroundColor = UIColor.init(red: 231.0/255.0, green: 231.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        if tileSet == nil {
            tileSet = TileSet.init(dimensions: tileDimensions)
            tileSet!.delegate = self
            layTiles()
        }
        for tile in tileSet!.tiles {
            addSubview(tile)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
