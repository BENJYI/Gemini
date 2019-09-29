//
//  GameViewController.swift
//  Gemini
//
//  Created by Benjamin Yi on 6/26/18.
//  Copyright © 2018 Benjamin Yi. All rights reserved.
//

import UIKit

extension GameViewController: CursorViewDelegate {
    func setSelectedTag(_ tag: Int) {
        selectedTag = tag
    }
}

class GameViewController: UIViewController, UIScrollViewDelegate {
    private var boardView: BoardView!
    private var selectedTag: Int = 1001
    private var panningTag: Int = 1001
    private var tileDimensions: CGPoint?
    private var scrollView: ShiftingView?
    private var trans: CGPoint = CGPoint.init(x: 0.0, y: 0.0)
    private var cursor: CursorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        // Calculate dimensions here
        // Gesture dimensions
        view.layer.contents = UIImage(named: "gemini-bg")!.cgImage
        
        // Tile dimensions
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let bvh: CGFloat = screenHeight
        let bvw: CGFloat = bvh * (16.0/11.7)
        let bvx: CGFloat = (screenWidth / 2) - (bvw / 2)
        let bvy: CGFloat = 0.0
        boardView = BoardView.init(frame: CGRect.init(x: bvx, y: bvy, width: bvw, height: bvh))
        let gestureDim = CGSize.init(width: boardView.frame.size.width / 2, height: boardView.frame.size.height)
        let tileWidth: CGFloat = boardView.frame.size.width / 16
        let tileHeight: CGFloat = boardView.frame.size.height / 9
        tileDimensions = CGPoint.init(x: tileWidth, y: tileHeight)
        
        let movementArea = UIView.init(frame: CGRect.init(x: boardView.frame.origin.x + gestureDim.width, y: boardView.frame.origin.y, width: gestureDim.width, height: gestureDim.height))
        let movementGesture = UIPanGestureRecognizer.init(target: self, action: #selector(moveTile))
        movementArea.addGestureRecognizer(movementGesture)
        
        cursor = CursorView.init(frame: CGRect.init(origin: boardView.frame.origin, size: boardView.frame.size), td: tileDimensions!, delegate: self)
        
        // Scrollview instantiation
        scrollView = ShiftingView.init(frame: boardView.frame)
        scrollView?.delegate = self
        scrollView?.contentSize = self.scrollView!.frame.size
        scrollView?.isUserInteractionEnabled = false
        
        view.addSubview(boardView)
        view.addSubview(scrollView!)
        view.addSubview(cursor)
        view.addSubview(movementArea)
        
        if let tile = (view.viewWithTag(selectedTag) as! TileView?) {
            tile.enableHighlightedState(true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: tile movement and matching
    
    @objc func moveTile(recognizer: UIPanGestureRecognizer) {
        // Tile moveement algorithms
        
        // TODO: fix this temporary fix that returns if there is no selected tile
        let existingTile: TileView? = view.viewWithTag(selectedTag) as! TileView?
        if existingTile == nil {
            return
        }
        
        var moveableTiles: [TileView] = []
        
        if recognizer.state == .began {
            let velocity: CGPoint = recognizer.velocity(in: view)
            var vectorDirection: Int = 0
            
            if abs(velocity.x) > abs(velocity.y) {
                scrollView!.direction = velocity.x > 0 ? "left" : "right"
                vectorDirection = Int(CGFloat(velocity.x) / abs(velocity.x))
            } else {
                scrollView!.direction = velocity.y > 0 ? "up" : "down"
                vectorDirection = Int(CGFloat(velocity.y) / abs(velocity.y))
            }
            scrollView!.vectorDirection = vectorDirection
            
            for tile in getScrollableTiles() {
                moveableTiles.append(tile)
                tile.removeFromSuperview()
                scrollView!.shiftingTiles.append(tile)
                scrollView!.addSubview(tile)
            }
        }
        
        let translation: CGPoint = recognizer.translation(in: view)
        var offset: CGPoint = CGPoint.init(x: 0.0, y: 0.0)
        
        if scrollView!.isHorizontal() {
            offset.x = (-1)*translation.x
            offset.y = 0
        } else {
            offset.x = 0
            offset.y = (-1)*translation.y
        }
        
        scrollView!.setContentOffset(offset, animated: false)
        
        // -------------------------------------------------------------------------
        // ----- REPEATED CODE FIX THIS --------------------------------------------
        // ----- (check in updateTiles) --------------------------------------------
        // -------------------------------------------------------------------------
        var panDistance:  CGFloat = 0.0
        var length:       CGFloat = 0.0
        var tagIncrement: Int     = 0
        
        if scrollView!.isHorizontal() {
            panDistance = (-1)*scrollView!.contentOffset.x
            length = tileDimensions!.x
            tagIncrement = 1
        } else {
            panDistance = (-1)*scrollView!.contentOffset.y
            length = tileDimensions!.y
            tagIncrement = 16
        }
        
        let tileOffset: CGFloat = round(panDistance / length)
        let tempTag: Int = Int(tileOffset * CGFloat(tagIncrement) + CGFloat(selectedTag))
        // Matching tile checker
        // Whereever the new tile location is, check matching up down or right
        
        if recognizer.state == .ended {
            let currentSelectedTile: TileView = view.viewWithTag(selectedTag) as! TileView
            if let matchingTile: TileView = (getMatch(with: TileTag(tempTag), type: currentSelectedTile.type!)) {
                updateTiles(moveableTiles)
                // matchTile(with: selectedTile)
                matchingTile.removeFromSuperview()
                currentSelectedTile.removeFromSuperview()
            } else {
                scrollView!.contentOffset = CGPoint.init(x: 0.0, y: 0.0)
                returnTiles()
            }
        }
    }
    
    func getScrollableTiles() -> [TileView] {
        var tiles: [TileView] = []
        let selectedTile: TileView = view.viewWithTag(selectedTag) as! TileView
        tiles.append(selectedTile)
        
        var increment: Int = 0
        var limit: Int = 0
        
        if scrollView!.isHorizontal() {
            increment = 1
            if scrollView!.vectorDirection < 0 {
                increment = (-1)*increment
                limit = selectedTile.leadingTag
            } else {
                limit = selectedTile.trailingTag
            }
        } else {
            increment = 16
            if scrollView!.vectorDirection < 0 {
                increment = (-1)*increment
                limit = selectedTile.topTag
            } else {
                limit = selectedTile.bottomTag
            }
        }
        
        var emptyTiles: Int = 0
        
        for tag in stride(from: selectedTile.tag+increment, through: limit, by: increment) {
            var tile: TileView? = view.viewWithTag(tag) as! TileView?
            if tile != nil {
                tiles.append(tile!)
            } else {
                var itag = tag
                while tile == nil && itag != limit + increment {
                    emptyTiles += 1
                    itag += increment
                    tile = view.viewWithTag(itag) as? TileView
                }
                break
            }
        }
        
        scrollView!.setPanLimits(with: emptyTiles, withDimesions: tileDimensions!)
        return tiles
    }
    
    func getMatch(with tempTag: TileTag, type: String) -> TileView? {
        var increment: Int = -16
        var currVal: Int = tempTag.val
        
        var matchingTile: TileView? = nil
        while matchingTile == nil && currVal + increment >= tempTag.top && scrollView!.direction != "up" {
            currVal += increment
            matchingTile = view.viewWithTag(currVal) as! TileView?
        }
        
        if matchingTile?.type == type {
            return matchingTile
        }
        
        increment = 1
        currVal = tempTag.val
        
        matchingTile = nil
        while matchingTile == nil && currVal + increment <= tempTag.trailing && scrollView!.direction != "right" {
            currVal += increment
            matchingTile = view.viewWithTag(currVal) as! TileView?
        }
        
        if matchingTile?.type == type {
            return matchingTile
        }
        
        increment = 16
        currVal = tempTag.val
        
        matchingTile = nil
        while matchingTile == nil && currVal + increment <= tempTag.bottom && scrollView!.direction != "down" {
            currVal += increment
            matchingTile = view.viewWithTag(currVal) as! TileView?
        }
        
        if matchingTile?.type == type {
            return matchingTile
        }
        
        increment = -1
        currVal = tempTag.val
        
        matchingTile = nil
        while matchingTile == nil && currVal + increment >= tempTag.leading && scrollView!.direction != "left" {
            currVal += increment
            matchingTile = view.viewWithTag(currVal) as! TileView?
        }
        
        if matchingTile?.type == type {
            return matchingTile
        }
        // Will eventually need to fix it to return an array of all matches
        return nil
    }
    
    func updateTiles(_ tiles: [TileView]) {
        var panDistance: CGFloat = 0.0
        var length: CGFloat = 0.0
        var tagIncrement: Int = 0
        
        if (scrollView!.isHorizontal()) {
            panDistance = (-1)*scrollView!.contentOffset.x
            length = tileDimensions!.x
            tagIncrement = 1
        } else {
            panDistance = (-1)*scrollView!.contentOffset.y
            length = tileDimensions!.y
            tagIncrement = 16
        }
        
        let tileOffset: CGFloat = round(panDistance / length)
        scrollView!.contentOffset = CGPoint.init(x: 0.0, y: 0.0)
        for tile in scrollView!.shiftingTiles {
            var newCenter: CGPoint?
            if scrollView!.isHorizontal() {
                newCenter = CGPoint.init(x: tile.center.x + (tileOffset * length), y: tile.center.y)
            } else {
                newCenter = CGPoint.init(x: tile.center.x, y: tile.center.y + (tileOffset * length))
            }
            tile.tag += Int(tileOffset * CGFloat(tagIncrement))
            tile.center = newCenter!
        }
        returnTiles()
        selectedTag += Int(tileOffset * CGFloat(tagIncrement))
    }
    
    func returnTiles() {
        for tile in scrollView!.shiftingTiles {
            tile.removeFromSuperview()
            boardView.addSubview(tile)
        }
        scrollView!.shiftingTiles = []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
