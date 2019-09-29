//
//  TileView.swift
//  Gemini
//
//  Created by Benjamin Yi on 6/26/18.
//  Copyright © 2018 Benjamin Yi. All rights reserved.
//

import UIKit

protocol TileViewDelegate: AnyObject {
    func didSelectTileWithTag(tag: Int)
}

class TileView: UIView {
    var type: String?
    var frameInset = CGPoint.init()
    var tileDimensions: CGPoint?
    var tileTag: TileTag?
    weak var delegate: TileViewDelegate?
    
    init(frame: CGRect, type: String, tag: Int) {
        super.init(frame: frame)
        self.type = type
        self.tag = tag
        self.tileTag = TileTag(tag)
        self.frame = frame
            
        frameInset.x = frame.size.width * 0.5
        frameInset.y = frame.size.height * 0.5
        tileDimensions = CGPoint.init(x: frame.size.width, y: frame.size.height)
        layer.borderWidth = 0.0;
        layer.shadowOpacity = 0.0;
        layer.shadowOffset = CGSize.init(width: 0, height: 3)
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.0
        layer.shadowOpacity = 0.0
        
        let imageView = UIImageView.init(image: UIImage.init(named: type))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: [:], views: ["imageView" : imageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: [:], views: ["imageView" : imageView]))
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(selectNewTile))
        addGestureRecognizer(tapGesture)
        
        if type.contains("flower") {
            self.type = "flower";
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func enableHighlightedState(_ highlightEnabled: Bool) {
        if highlightEnabled {
            frame = frame.insetBy(dx: -frameInset.x, dy: -frameInset.y)
            layer.borderWidth = 0.9
            layer.shadowOpacity = 0.8
            superview?.bringSubviewToFront(self)
        } else {
            frame = frame.insetBy(dx: frameInset.x, dy: frameInset.y)
            layer.borderWidth = 0.0
            layer.shadowOpacity = 0.0
        }
    }
    
    var column:      Int { get { return ((tag - 1001) % 16) + 1 } }
    var row:         Int { get { return ((tag - 1001) / 16) + 1 } }
    var leadingTag:  Int { get { return (((tag - 1001) / 16) * 16) + 1001 } }
    var trailingTag: Int { get { return (((tag - 1001) / 16) * 16) + 1016 } }
    var topTag:      Int { get { return ((tag - 1001) % 16) + 1001 } }
    var bottomTag:   Int { get { return ((tag - 1001) % 16) + 1129 } }

    @objc func selectNewTile() {
        delegate?.didSelectTileWithTag(tag: tag)
    }
}
