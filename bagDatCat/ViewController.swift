//
//  ViewController.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Saved foundational properties for the mainViewController
    var mainViewWidth:CGFloat = 0.0;
    var mainViewHeight:CGFloat = 0.0;
    var unitView:CGFloat = 0.0;
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        saveMainViewFoundationalProperties();
    }
    
    func saveMainViewFoundationalProperties() {
        mainViewWidth = mainViewController.frame.height * 9.0 / 16.0;
        mainViewHeight = mainViewController.frame.height;
        unitView = mainViewHeight / 18.0;
    }


}

