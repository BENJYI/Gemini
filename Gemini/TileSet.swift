//
//  TileSet.swift
//  Gemini
//
//  Created by Benjamin Yi on 6/26/18.
//  Copyright © 2018 Benjamin Yi. All rights reserved.
//

import UIKit

class TileSet: NSObject {
    
    var tiles: [String] = []
    
    override init() {
        super.init()
        let suits: [String] = [
            "pin1", "pin2", "pin3", "pin4", "pin5", "pin6", "pin7", "pin8", "pin9", "bamboo1", "bamboo2", "bamboo3", "bamboo4", "bamboo5", "bamboo6", "bamboo7", "bamboo8", "bamboo9", "man1", "man2", "man3", "man4", "man5", "man6", "man7", "man8", "man9"
        ]
        
        let winds: [String] = ["wind-north", "wind-east", "wind-south", "wind-west"]
        let dragons: [String] = ["dragon-chun", "dragon-haku", "dragon-green"]
//        let flowers: [String] = ["flower-1", "flower-2", "flower-3", "flower-4"]
        
        var tmp: [String] = []
        
        for _ in 1...4 {
            tmp = tmp + suits + winds + dragons
        }
        for _ in 1...8 {
            tmp.append("flower")
        }
        
        tiles = tmp
        randomizeTiles()
    }
    
    func randomizeTiles() {
        var tmp = tiles
        tiles = []
        for _ in 0..<tmp.count
        {
            let rand = Int(arc4random_uniform(UInt32(tmp.count)))
            tiles.append(tmp[rand])
            tmp.remove(at: rand)
        }
    }
}
