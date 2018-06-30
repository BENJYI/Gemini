//
//  GameViewController.swift
//  Gemini
//
//  Created by Benjamin Yi on 6/26/18.
//  Copyright © 2018 Benjamin Yi. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    @IBOutlet weak var boardView: BoardView?
    private var selectedTag: Int = 1001
    private var panningTag: Int = 1001
    private var gestureCancelled: Bool = false
    private var tileDimensions: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Calculate dimensions here
        // Gesture dimensions
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
        let movementGesture = UITapGestureRecognizer.init(target: self, action: #selector(moveTile))
        movementArea.addGestureRecognizer(movementGesture)
        view.addSubview(movementArea)
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
    
    @objc func moveTile(recognizer: UITapGestureRecognizer) {
        // Tile moveement algorithms
        
        // Matching tile checker
        // Whereever the new tile location is, check matching up down or right
        
        if recognizer.state == .ended {
            var selectedTile: TileView = view.viewWithTag(selectedTag) as! TileView
            if let matchingTile: TileView = (getMatch(with: selectedTile)) {
            } else {
            }
        }
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
