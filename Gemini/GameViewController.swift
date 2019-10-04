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

struct TileState {
    var tile: TileView!
    var tag: Int!
    var center: CGPoint!
}

struct HistoryItem {
    var prev: [TileState]!
    var next: [TileState]!
    var match1: TileView!
    var match2: TileView!
}

class GameViewController: UIViewController, UIScrollViewDelegate {
    private var boardView: BoardView!
    private var selectedTag: Int = 1001
    private var panningTag: Int = 1001
    private var tileDimensions: CGPoint?
    private var scrollView: ShiftingView?
    private var trans: CGPoint = CGPoint.init(x: 0.0, y: 0.0)
    private var cursor: CursorView!
    private var history: [HistoryItem] = []
    private var historyStep: Int = -1
    private var backButton: UIButton!
    private var forwardButton: UIButton!
    private var menuButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        // Calculate dimensions here
        // Gesture dimensions
        
        view.backgroundColor = UIColor.init(red: 231.0/255.0, green: 231.0/255.0, blue: 227.0/255.0, alpha: 1.0)
        
        // Tile dimensions
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let bvh: CGFloat = screenHeight
        let bvw: CGFloat = bvh * (16.0/11.7)
        let bvx: CGFloat = (screenWidth / 2) - (bvw / 2)
        let bvy: CGFloat = 0.0
        
        let border = UIView.init(frame: CGRect.init(x: bvx-3, y: bvy-1, width: bvw+6, height: bvh+2))
        border.backgroundColor = UIColor.clear
        border.layer.borderColor = UIColor.gray.cgColor
        border.layer.borderWidth = 1.0
        view.addSubview(border)
            
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
        
        let borderLeftX = border.frame.origin.x
        let borderRightX = border.frame.origin.x + border.frame.size.width
        let buttonInset = borderLeftX * 0.40 / 2
        let buttonWidth = borderLeftX * 0.60
        let buttonY = (bvh - buttonWidth) / 2
        let buttonEI = buttonInset * 0.8
        
        backButton = UIButton.init(type: .system)
        backButton.frame = CGRect.init(x: buttonInset, y: buttonY, width: buttonWidth, height: buttonWidth)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.setImage(UIImage.init(named: "left-arrow-icon"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: buttonEI, left: buttonEI, bottom: buttonEI, right: buttonEI)
        backButton.tintColor = UIColor.darkText
        backButton.layer.borderWidth = 1.5
        backButton.layer.borderColor = UIColor.darkText.cgColor
        backButton.layer.cornerRadius = buttonWidth / 2
        backButton.layer.opacity = 0.0
        
        forwardButton = UIButton.init(type: .system)
        forwardButton.frame = CGRect.init(x: borderRightX + buttonInset, y: buttonY, width: buttonWidth, height: buttonWidth)
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        forwardButton.setImage(UIImage.init(named: "right-arrow-icon"), for: .normal)
        forwardButton.imageEdgeInsets = UIEdgeInsets.init(top: buttonEI, left: buttonEI, bottom: buttonEI, right: buttonEI)
        forwardButton.tintColor = UIColor.darkText
        forwardButton.layer.borderWidth = 1.5
        forwardButton.layer.borderColor = UIColor.darkText.cgColor
        forwardButton.layer.cornerRadius = buttonWidth / 2
        forwardButton.layer.opacity = 0.0
        
        menuButton = UIButton.init(type: .system)
        menuButton.frame = CGRect.init(x: borderRightX + buttonInset-10, y: buttonInset-10, width: buttonWidth+20, height: buttonWidth/2 + 20)
        menuButton.addTarget(self, action: #selector(resetTiles), for: .touchUpInside)
        menuButton.backgroundColor = UIColor.gray
        menuButton.setTitle("RESET", for: .normal)
        menuButton.setTitleColor(UIColor.darkText, for: .normal)
        menuButton.layer.cornerRadius = 4
        
        view.addSubview(backButton)
        view.addSubview(forwardButton)
        view.addSubview(menuButton)
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
                updateTiles(moveableTiles, match1: matchingTile, match2: currentSelectedTile)
                UIView.animate(withDuration: 0.25, animations: {
                    matchingTile.layer.opacity = 0.0
                    currentSelectedTile.layer.opacity = 0.0
                }, completion: { _ in
                    matchingTile.removeFromSuperview()
                    currentSelectedTile.removeFromSuperview()
                    matchingTile.layer.opacity = 1.0
                    currentSelectedTile.layer.opacity = 1.0
                })
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
    
    func updateTiles(_ tiles: [TileView], match1: TileView, match2: TileView) {
        var prev: [TileState] = []
        var next: [TileState] = []
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
            prev.append(TileState(tile: tile, tag: tile.tag, center: tile.center))
            var newCenter: CGPoint?
            if scrollView!.isHorizontal() {
                newCenter = CGPoint.init(x: tile.center.x + (tileOffset * length), y: tile.center.y)
            } else {
                newCenter = CGPoint.init(x: tile.center.x, y: tile.center.y + (tileOffset * length))
            }
            tile.tag += Int(tileOffset * CGFloat(tagIncrement))
            tile.center = newCenter!
            next.append(TileState(tile: tile, tag: tile.tag, center: tile.center))
        }
        while (historyStep < history.count-1) {
            _ = history.popLast()
        }
        history.append(HistoryItem(prev: prev, next: next, match1: match1, match2: match2))
        historyStep += 1
        
        if backButton.layer.opacity == 0.0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.backButton.layer.opacity = 1.0
            })
        }
        
        if forwardButton.layer.opacity == 1.0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.forwardButton.layer.opacity = 0.0
            })
        }
        
        returnTiles()
        selectedTag += Int(tileOffset * CGFloat(tagIncrement))
    }
    
    @objc func resetTiles() {
        boardView.tileSet!.randomizeTiles()
        boardView.layTiles()
        history = []
        historyStep = -1
        backButton.layer.opacity = 0.0
        forwardButton.layer.opacity = 0.0
    }
    
    @objc func goBack() {
        if (historyStep == -1) {
            return
        }
        let historyItem: HistoryItem = history[historyStep]
        historyItem.match1.layer.opacity = 0.0
        historyItem.match2.layer.opacity = 0.0
        self.boardView!.addSubview(historyItem.match1)
        self.boardView!.addSubview(historyItem.match2)
        
        UIView.animate(withDuration: 0.5, animations: {
            historyItem.match1.layer.opacity = 1.0
            historyItem.match2.layer.opacity = 1.0
        }, completion: { finished in
        })

        UIView.animate(withDuration: 0.3, animations: {
            for state in historyItem.prev {
                state.tile.tag = state.tag
                state.tile.center = state.center
            }
        })
        historyStep -= 1
        
        if forwardButton.layer.opacity == 0.0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.forwardButton.layer.opacity = 1.0
            })
        }
        
        if backButton.layer.opacity == 1.0 && historyStep == -1  {
            UIView.animate(withDuration: 0.3, animations: {
                self.backButton.layer.opacity = 0.0
            })
        } else if backButton.layer.opacity == 0.0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.backButton.layer.opacity = 1.0
            })
        }
    }
    
    @objc func goForward() {
        if (historyStep == history.count-1) {
            return
        }
        
        historyStep += 1
        
        let historyItem: HistoryItem = history[historyStep]
        historyItem.match1.layer.opacity = 1.0
        historyItem.match2.layer.opacity = 1.0
        UIView.animate(withDuration: 0.5, animations: {
            for state in historyItem.next {
                state.tile.tag = state.tag
                state.tile.center = state.center
            }
        }, completion: { finished in
            UIView.animate(withDuration: 0.3, animations: {
                historyItem.match1.layer.opacity = 0.0
                historyItem.match2.layer.opacity = 0.0
            }, completion: { finished in
                historyItem.match1.removeFromSuperview()
                historyItem.match2.removeFromSuperview()
                historyItem.match1.layer.opacity = 1.0
                historyItem.match2.layer.opacity = 1.0
            })
        })
        
        if backButton.layer.opacity == 0.0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.backButton.layer.opacity = 1.0
            })
        }
        
        if forwardButton.layer.opacity == 1.0 && historyStep == history.count-1  {
            UIView.animate(withDuration: 0.3, animations: {
                self.forwardButton.layer.opacity = 0.0
            })
        } else if forwardButton.layer.opacity == 0.0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.forwardButton.layer.opacity = 1.0
            })
        }
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
