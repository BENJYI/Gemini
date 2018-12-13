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
    var emitter = CAEmitterLayer.init()
    
    init(frame: CGRect, type: String, tag: Int) {
        super.init(frame: frame)
        self.type = type
        self.tag = tag
        self.tileTag = TileTag(tag)
        self.frame = frame
            
        frameInset.x = frame.size.width * 0.5
        frameInset.y = frame.size.height * 0.5
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
        
        
        
        
        
        
        
        
        let multiplier: Float = 0.25
        emitter.emitterPosition = CGPoint.init(x: frame.origin.x + frame.size.width/2, y: frame.origin.y + frame.size.height/2)
        emitter.emitterMode = kCAEmitterLayerOutline
        emitter.emitterShape = kCAEmitterLayerSurface
        emitter.renderMode = kCAEmitterLayerAdditive
        emitter.emitterSize = CGSize.init(width: 1.0, height: 0)
        
        let particle = CAEmitterCell.init()
        particle.emissionLongitude = 0.5
        particle.birthRate = multiplier * 1000.00
        particle.lifetime = multiplier
        particle.lifetimeRange = multiplier * 0.35
        particle.velocity = 180
        particle.velocityRange = 130
        particle.emissionRange = 1.1
        particle.scaleSpeed = 1.0
        particle.color = UIColor.init(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.3).cgColor
        particle.contents = UIImage.init(named: "spark.png")!.cgImage
        particle.name = "particle"
        particle.scale = 0.1
        emitter.emitterCells = [particle]z
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func enableHighlightedState(_ highlightEnabled: Bool) {
        if highlightEnabled {
            frame = frame.insetBy(dx: -frameInset.x, dy: -frameInset.y)
            layer.borderWidth = 0.9
            layer.shadowOpacity = 0.8
            superview?.bringSubview(toFront: self)
            layer.addSublayer(emitter)
        } else {
            frame = frame.insetBy(dx: frameInset d.x, dy: frameInset.y)
            layer.borderWidth = 0.3
            layer.shadowOpacity = 0.0
            emitter.removeFromSuperlayer()
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
