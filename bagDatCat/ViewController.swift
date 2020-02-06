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
        // Do any additional setup after loading the view.
        let view:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 100));
        mainViewController!.addSubview(view);
        view.backgroundColor = UIColor.white;
//        CenterKit.center(childView: view, parentRect: view.frame, childRect: mainViewController!.frame);
    }
    
    func saveMainViewFoundationalProperties() {
        mainViewWidth = mainViewController.frame.width * 9.0 / 16.0;
        mainViewHeight = mainViewController.frame.height;
        unitView = mainViewHeight / 18.0;
    }


}

