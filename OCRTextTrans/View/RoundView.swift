//
//  RoundView.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/09.
//

import Foundation
import UIKit

class RoundView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.width / 2
    }
}
