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
    var frameInset: CGPoint?
    var tileDimensions: CGPoint?
    weak var delegate: TileViewDelegate?
    
    init(frame: CGRect, type: String, tag: Int) {
        super.init(frame: frame)
        self.type = type
        self.tag = tag
        self.frame = frame
            
        frameInset = CGPoint.init(x: frame.size.width * 0.1, y: frame.size.height * 0.1)
        tileDimensions = CGPoint.init(x: frame.size.width, y: frame.size.height)
        layer.borderWidth = 0.3
        layer.borderColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize.init(width: 0, height: 3)
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.0
        layer.shadowOpacity = 0.0
        
        let imageView = UIImageView.init(image: UIImage.init(named: type))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: [:], views: ["imageView" : imageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: [:], views: ["imageView" : imageView]))
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(selectNewTile))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func enableHighlightedState(_ highlightEnabled: Bool) {
        if highlightEnabled {
            frame.insetBy(dx: -frameInset!.x, dy: -frameInset!.y)
            layer.borderWidth = 0.9
            layer.shadowOpacity = 0.8
            superview?.bringSubview(toFront: self)
        } else {
            frame.insetBy(dx: frameInset!.x, dy: frameInset!.y)
            layer.borderWidth = 0.3
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
