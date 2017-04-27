//
//  TTHomeTableTableViewController.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 4/26/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//

import UIKit
import MagicPie

class TTHomeTableTableViewController: UITableViewController {
    
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    var pieLayer : PieLayer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieLayer = PieLayer()
        pieLayer.frame = pieView.frame
        pieLayer.minRadius = Float(pieView.frame.width/4)
        pieLayer.maxRadius = Float(pieView.frame.width/2)
        
        view.layer.addSublayer(pieLayer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pieLayer.addValues([PieElement(value: 5.0, color: UIColor.init(red: 244/255.0, green: 115/255.0, blue: 0/255.0, alpha: 1)),
                            PieElement(value: 5.0, color: UIColor.lightGray)], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
