//
//  UICScrollView.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/23/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import SwiftUI

class UICScrollView: UIScrollView {
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame:CGRect) {
        super.init(frame:frame);
        super.layer.borderWidth = super.frame.width * 0.02;
        super.layer.cornerRadius = super.frame.width * 0.04;
        super.backgroundColor = UIColor.clear;
        parentView.addSubview(self);
    }
    
}
