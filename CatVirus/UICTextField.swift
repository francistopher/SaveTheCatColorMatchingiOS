//
//  UICTextField.swift
//  CatVirus
//
//  Created by Christopher Francisco on 2/22/20.
//  Copyright © 2020 Christopher Francisco. All rights reserved.
//

import Foundation
import SwiftUI

class UICTextField:UITextField, UITextFieldDelegate {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(parentView:UIView, frame:CGRect) {
        super.init(frame: frame);
        parentView.addSubview(self);
        self.textAlignment = NSTextAlignment.center;
        self.font = UIFont.boldSystemFont(ofSize: self.frame.height * 0.4);
        self.delegate = self;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get current text
        let currentText = textField.text ?? ""
        // Read range that is being changed
        guard let stringRange = Range(range, in: currentText) else { return false }
        // Remove spaces being typed
        if (currentText.replacingCharacters(in: stringRange, with: string).contains(" ")) {
            return false;
        }
        // Add new text to existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        // Limit result
        return updatedText.count <= 16
    }
}
