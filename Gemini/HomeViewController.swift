//
//  HomeViewController.swift
//  Gemini
//
//  Created by Benjamin Yi on 9/30/19.
//  Copyright © 2019 Benjamin Yi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startNewGame(sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "startSegue", sender: nil)
        }
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
