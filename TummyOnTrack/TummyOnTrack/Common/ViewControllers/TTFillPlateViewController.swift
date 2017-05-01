//
//  TTFillPlateViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/30/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit

class TTFillPlateViewController: UIViewController {

    @IBOutlet weak var plateView: UIView!
    @IBOutlet weak var fruitsButton: UIButton!
    
    @IBOutlet weak var veggiesButton: UIButton!
    
    @IBOutlet weak var mainDishButton: UIButton!
    
    @IBOutlet weak var dairyButton: UIButton!
    
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var dessertButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        plateView.layer.masksToBounds = true
        plateView.layer.cornerRadius = plateView.frame.height/2
        fruitsButton.layer.cornerRadius = fruitsButton.frame.height/2
        veggiesButton.layer.cornerRadius = veggiesButton.frame.height/2
        mainDishButton.layer.cornerRadius = mainDishButton.frame.height/2
        dairyButton.layer.cornerRadius = dairyButton.frame.height/2
        drinkButton.layer.cornerRadius = drinkButton.frame.height/2
        dessertButton.layer.cornerRadius = dessertButton.frame.height/2
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
