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
        let selectionArea = UIView.init(frame: CGRect.init(x: boardView!.frame.origin.x, y: boardView!.frame.origin.y, width: boardView!.frame.size.width / 2, height: boardView!.frame.size.height))
        let selectionGesture = UIPanGestureRecognizer.init(target: self, action: #selector(selectTile))
        
        selectionArea.addGestureRecognizer(selectionGesture)
        view.addSubview(selectionArea)
        
        let tileWidth: CGFloat = boardView!.frame.size.width / 16
        let tileHeight: CGFloat = boardView!.frame.size.height / 9
        tileDimensions = CGPoint.init(x: tileWidth, y: tileHeight)
        
    }

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
        
        var movementThreshold: Int = 0
        
        if fabs(translation.x) > fabs(translation.y) {
            if translation.x < 0 {
                movementThreshold = -1 * ((selectedTag - 1001) % 16)
            } else {
                movementThreshold = 15 - ((selectedTag - 1001) % 16)
            }
            if abs(horizonalShift) >= abs(movementThreshold) {
                horizonalShift = movementThreshold
            }
        } else {
            if translation.y < 0 {
                movementThreshold = -1 * ((selectedTag - 1001) / 16)
            } else {
                movementThreshold =  8 - ((selectedTag - 1001) / 16)
            }
            if abs(verticalShift) >= abs(movementThreshold) {
                verticalShift = movementThreshold
            }
        }
        
        var translatedTag: Int = selectedTag + horizonalShift + (verticalShift * 16)
        
        if translatedTag < 1001 { translatedTag += 16 }
        if translatedTag > 1144 { translatedTag -= 16 }
        
        return translatedTag;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
