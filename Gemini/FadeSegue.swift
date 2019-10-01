//
//  StartSegue.swift
//  Gemini
//
//  Created by Benjamin Yi on 9/30/19.
//  Copyright © 2019 Benjamin Yi. All rights reserved.
//

import UIKit

class FadeSegue: UIStoryboardSegue {
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        let sv = source as UIViewController
        let dv = destination as UIViewController
        let window = UIApplication.shared.keyWindow!
        
        dv.view.alpha = 0.0
        window.insertSubview(dv.view, belowSubview: sv.view)
        
        UIView.animate(withDuration: 1.0, animations: {
            sv.view.alpha = 0.0
            dv.view.alpha = 1.0
        }, completion: { finished in
            sv.view.alpha = 1.0
            sv.present(dv, animated: false, completion: nil)
        })
    }
}
