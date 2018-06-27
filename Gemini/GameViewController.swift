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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let selectionArea = UIView.init(frame: CGRect.init(x: boardView!.frame.origin.x, y: boardView!.frame.origin.y, width: boardView!.frame.size.width / 2, height: boardView!.frame.size.height))
        let selectionGesture = UIPanGestureRecognizer.init(target: self, action: #selector(selectTile))
        
        selectionArea.addGestureRecognizer(selectionGesture)
        view.addSubview(selectionArea)
    }

    @objc func selectTile(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            print("selection gesture STARTED")
        }
        
        if recognizer.state == .ended {
            print("selection gesture ENDED")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
