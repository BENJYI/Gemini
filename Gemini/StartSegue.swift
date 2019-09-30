//
//  StartSegue.swift
//  Gemini
//
//  Created by Benjamin Yi on 9/30/19.
//  Copyright © 2019 Benjamin Yi. All rights reserved.
//

import UIKit

class StartSegue: UIStoryboardSegue {
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        guard let destinationView = destination.view else {
            self.source.present(self.destination, animated: false, completion: nil)
            return
        }
        
        destinationView.alpha = 0.0
        self.source.view?.addSubview(destinationView)
        
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
            destinationView.alpha = 1.0
        }, completion: { finished in
            self.source.present(self.destination, animated: false, completion: nil)
        })
    }
}
