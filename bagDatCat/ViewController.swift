//
//  ViewController.swift
//  bagDatCat
//
//  Created by Christopher Francisco on 2/6/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Main View Controller Properties
    var mainViewWidth:CGFloat = 0.0;
    var mainViewHeight:CGFloat = 0.0;
    var unitView:CGFloat = 0.0;
    
    // Intro Label properties
    var introLabel:CUILabel? = nil;
    
    @IBOutlet var mainViewController: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        saveMainViewFoundationalProperties();
        configureIntroLabel();
    }
    
    func saveMainViewFoundationalProperties() {
        mainViewWidth = mainViewController.frame.height * 9.0 / 16.0;
        mainViewHeight = mainViewController.frame.height;
        unitView = mainViewHeight / 18.0;
    }
    
    func configureIntroLabel(){
        introLabel = CUILabel(parentView: mainViewController, x: 0, y: 0, width: mainViewWidth * 0.5, height: mainViewHeight * 0.15, backgroundColor: UIColor.black, textColor: UIColor.white, font: UIFont.boldSystemFont(ofSize: 48.0), text: "bagDatCat");
        CenterUIKit.center(childView: introLabel!, parentRect: mainViewController.frame, childRect: introLabel!.frame);
    }


}

