//
//  SplashViewController.swift
//  Gemini
//
//  Created by Benjamin Yi on 9/30/19.
//  Copyright © 2019 Benjamin Yi. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.alpha = 0.0
        authorLabel.alpha = 0.0
        
        UIView.animate(withDuration: 1.0, animations: {
            self.titleLabel.alpha = 1.0
        })
        
        UIView.animate(withDuration: 2.0, animations: {
            self.authorLabel.alpha = 2.0
        }, completion: { finished in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "startSegue", sender: nil)
            }
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
