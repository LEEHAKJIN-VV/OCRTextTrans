//
//  MainNavigationController.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/09.
//

import Foundation
import UIKit

class MainNavgationController: UINavigationController {
    
    override func viewDidLoad() {
        self.pushViewController(MainPage(), animated: false)
        super.viewDidLoad()
    }
    
}
