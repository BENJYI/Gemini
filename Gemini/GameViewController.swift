//
//  GameViewController.swift
//  Gemini
//
//  Created by Benjamin Yi on 6/26/18.
//  Copyright © 2018 Benjamin Yi. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var boardView: BoardView?
    private var selectedTag: Int = 1001
    private var panningTag: Int = 1001
    private var gestureCancelled: Bool = false
    private var tileDimensions: CGPoint?
    private var scrollView: ShiftingView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        // Calculate dimensions here
        // Gesture dimensions
        view.backgroundColor = .clear
        let gestureDim = CGSize.init(width: boardView!.frame.size.width / 2, height: boardView!.frame.size.height)
        
        // Tile dimensions
        let tileWidth: CGFloat = boardView!.frame.size.width / 16
        let tileHeight: CGFloat = boardView!.frame.size.height / 9
        tileDimensions = CGPoint.init(x: tileWidth, y: tileHeight)
        
        let selectionArea = UIView.init(frame: CGRect.init(x: boardView!.frame.origin.x, y: boardView!.frame.origin.y, width: gestureDim.width, height: gestureDim.height))
        let selectionGesture = UIPanGestureRecognizer.init(target: self, action: #selector(selectTile))
        selectionArea.addGestureRecognizer(selectionGesture)
        view.addSubview(selectionArea)
        
        let movementArea = UIView.init(frame: CGRect.init(x: boardView!.frame.origin.x + gestureDim.width, y: boardView!.frame.origin.y, width: gestureDim.width, height: gestureDim.height))
        let movementGesture = UIPanGestureRecognizer.init(target: self, action: #selector(moveTile))
        movementArea.addGestureRecognizer(movementGesture)
        view.addSubview(movementArea)
        
        // Scrollview instantiation
        scrollView = ShiftingView.init(frame: boardView!.frame)
        scrollView?.delegate = self
        scrollView?.contentSize = self.scrollView!.frame.size
        view.addSubview(scrollView!)
        scrollView?.isUserInteractionEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: tile selection

    @objc func selectTile(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            panningTag = selectedTag
            gestureCancelled = false
        }
        
        let translation: CGPoint = recognizer.translation(in: view)
        let panningTile: TileView? = (view.viewWithTag(panningTag) as? TileView)
        var newPanningTag = getTagWithTranslation(translation)
        if newPanningTag < 1001 { newPanningTag += 16 }
        else if newPanningTag > 1144 { newPanningTag -= 16 }
        
        if let newPanningTile: TileView? = (view.viewWithTag(newPanningTag) as? TileView?)
        {
            if newPanningTag != selectedTag {
                panningTag = newPanningTag
                panningTile?.enableHighlightedState(false)
                newPanningTile?.enableHighlightedState(true)
            }
        }
        
        if recognizer.state == .ended {
            selectedTag = panningTag
        }
    }

    func getTagWithTranslation(_ translation: CGPoint) -> Int {
        var horizonalShift: Int = Int((translation.x * 1.5) / tileDimensions!.x)
        var verticalShift: Int = Int((translation.y * 1.5) / tileDimensions!.y)
        
        if horizonalShift == 0 && verticalShift == 0 {
            return selectedTag
        }
        
        struct Coord {
            var x: Int
            var y: Int
        }
        
        var movementThreshold: Coord = Coord.init(x: 0, y: 0)

        if translation.x < 0 {
            movementThreshold.x = -1 * ((selectedTag - 1001) % 16)
        } else {
            movementThreshold.x = 15 - ((selectedTag - 1001) % 16)
        }
        if abs(horizonalShift) >= abs(movementThreshold.x) {
            horizonalShift = movementThreshold.x
        }
        
        if translation.y < 0 {
            movementThreshold.y = -1 * ((selectedTag - 1001) / 16)
        } else {
            movementThreshold.y =  8 - ((selectedTag - 1001) / 16)
        }
        if abs(verticalShift) >= abs(movementThreshold.y) {
            verticalShift = movementThreshold.y
        }
        
        var translatedTag: Int = selectedTag + horizonalShift + (verticalShift * 16)
        
        if translatedTag < 1001 { translatedTag += 16 }
        if translatedTag > 1144 { translatedTag -= 16 }
        
        return translatedTag;
    }
    
    // MARK: tile movement and matching
    
    @objc func moveTile(recognizer: UIPanGestureRecognizer) {
        // Tile moveement algorithms
        
//        if (!(TileView *)[self viewWithTag:selectedTileTag]) {
//            return;
//        }

        var rowTiles: [TileView] = []
        
        if recognizer.state == .began {
            let velocity: CGPoint = recognizer.velocity(in: view)
            var vectorDirection: Int = 0
            
            if fabs(velocity.x) > fabs(velocity.y) {
                scrollView!.direction = velocity.x > 0 ? "left" : "right"
                vectorDirection = Int(CGFloat(velocity.x) / fabs(velocity.x))
            } else {
                scrollView!.direction = velocity.y > 0 ? "up" : "down"
                vectorDirection = Int(CGFloat(velocity.y) / fabs(velocity.y))
            }
            scrollView!.vectorDirection = vectorDirection
            for tile in getScrollableTiles() {
                tile.removeFromSuperview()
                scrollView!.shiftingTiles.append(tile)
                scrollView!.addSubview(tile)
                print(tile.type!, tile.tag)
                print(scrollView!.shiftingTiles.count)
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
        
        scrollView?.contentOffset = offset
        
        // -------------------------------------------------------------------------
        // ----- REPEATED CODE FIX THIS --------------------------------------------
        // ----- (check in updateTiles) --------------------------------------------
        // -------------------------------------------------------------------------
        var panDistance:  CGFloat = 0.0
        var length:       CGFloat = 0.0
        var tagIncrement: Int     = 0
        
        if scrollView!.isHorizontal() {
            panDistance = (-1)*scrollView!.contentOffset.x;
            length = tileDimensions!.x;
            tagIncrement = 1;
        } else {
            panDistance = (-1)*scrollView!.contentOffset.y;
            length = tileDimensions!.y;
            tagIncrement = 16;
        }
        
        let tileOffset: CGFloat = round(panDistance / length)
        let tempTag: Int = Int(tileOffset * CGFloat(tagIncrement) + CGFloat(selectedTag))
        
        // Matching tile checker
        // Whereever the new tile location is, check matching up down or right
        
        if recognizer.state == .ended {
            for tile in scrollView!.shiftingTiles {
                print(tile.tag, tile.type!)
                tile.removeFromSuperview()
                boardView!.addSubview(tile)
            }
        }
    }
    
    func sendTiles(_ tiles: [TileView]) {
        for tile in tiles {
            tile.removeFromSuperview()
            scrollView!.shiftingTiles.append(tile)
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
                    tile = view.viewWithTag(tag) as? TileView
                }
                break
            }
        }
        
        scrollView!.setPanLimits(with: emptyTiles, withDimesions: tileDimensions!)
        return tiles
    }
    
    func getMatch(with tile: TileView) -> TileView? {
        findTag: for tag in stride(from: tile.tag-16, through: tile.topTag, by: -16) {
            if let matchingTile: TileView? = (view.viewWithTag(tag) as? TileView?) {
                if matchingTile?.type == tile.type {
                    return matchingTile
                } else {
                    break findTag
                }
            }
        }
        
        findTag: for tag in stride(from: tile.tag+1, through: tile.trailingTag, by: 1) {
            if let matchingTile: TileView? = (view.viewWithTag(tag) as? TileView?) {
                if matchingTile?.type == tile.type {
                    return matchingTile
                } else {
                    break findTag
                }
            }
        }
        
        findTag: for tag in stride(from: tile.tag+16, through: tile.bottomTag, by: 16) {
            if let matchingTile: TileView? = (view.viewWithTag(tag) as? TileView?) {
                if matchingTile?.type == tile.type {
                    return matchingTile
                } else {
                    break findTag
                }
            }
        }
        
        findTag: for tag in stride(from: tile.tag-1, through: tile.leadingTag, by: -1) {
            if let matchingTile: TileView? = (view.viewWithTag(tag) as? TileView?) {
                if matchingTile?.type == tile.type {
                    return matchingTile
                } else {
                    break findTag
                }
            }
        }
        
        // Will eventually need to fix it to return an array of all matches
        return nil
    }    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
