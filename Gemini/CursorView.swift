//
//  CursorView.swift
//  Gemini
//
//  Created by Benjamin Yi on 9/28/19.
//  Copyright © 2019 Benjamin Yi. All rights reserved.
//

import UIKit

protocol CursorViewDelegate {
    func setSelectedTag(_ tag: Int)
}

class CursorView: UIView {
    private var td: CGPoint = CGPoint.init(x: 0.0, y: 0.0)
    private var cursor: UIView!
    private var delegate: CursorViewDelegate?
    

    init(frame: CGRect, td: CGPoint, delegate: CursorViewDelegate) {
        self.delegate = delegate
        super.init(frame: frame)
        self.td = td
        backgroundColor = UIColor.init(red: 0.2, green: 0.4, blue: 0.6, alpha: 0.3)
        
        cursor = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: td.x, height: td.y))

        cursor.layer.borderWidth = 1.0
        cursor.layer.borderColor = UIColor.black.cgColor
        cursor.isUserInteractionEnabled = false
        
        let recognizer = UIPanGestureRecognizer.init(target: self, action: #selector(moveCursor))
        addGestureRecognizer(recognizer)
        addSubview(cursor)
    }
    
    @objc func moveCursor(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        var tx = cursor.center.x + translation.x
        var ty = cursor.center.y + translation.y
        if tx < (td.x / 2) { tx = td.x / 2 }
        if tx > frame.width - (td.x / 2) { tx = frame.width - (td.x / 2) }
        if ty < (td.y / 2) { ty = td.y / 2 }
        if ty > frame.height - (td.y / 2) { ty = frame.height - (td.y / 2) }
        
        cursor.center = CGPoint(x: tx, y: ty)
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        if recognizer.state == .ended {
            let row = round(cursor.frame.origin.y / td.y)
            let col = round(cursor.frame.origin.x / td.x)
            let nx = (col * td.x) + (td.x / 2)
            let ny = (row * td.y) + (td.y / 2)
            
            let newTag: Int = (Int(row) * 16) + Int(col) + 1001
            self.delegate!.setSelectedTag(newTag)
            
            UIView.animate(withDuration: 0.01, animations: {
                self.cursor.center = CGPoint(x: nx, y: ny)
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
