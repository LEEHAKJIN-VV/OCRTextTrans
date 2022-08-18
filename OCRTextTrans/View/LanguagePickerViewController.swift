//
//  LanguagePickerViewController.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/15.
//

import Foundation
import UIKit
import SnapKit
// MARK: - LanguagePickerViewController
class LanguagePickerViewController: UIViewController {
    private let screenWidth = UIScreen.main.bounds.width - 20
    private let screenHeight = UIScreen.main.bounds.height / 3
    private var languageList: [String] = ["한국어","영어","중국어","일본어"] // 임시 데이터
    
    var currentLanguage: String = "한국어"
    
    private lazy var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        pv.dataSource = self
        pv.delegate = self
        return pv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(pickerView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pickerView.snp.makeConstraints { make in // 제약 설정
            make.center.equalToSuperview()
        }
    }
    
}

// MARK: - picker view를 구성하는데 필요한 protocol
extension LanguagePickerViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.languageList.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { // component의 수를 반환
        return 1
    }
}

// MARK: - picker view delegate => picker를 선택했을때 관련된 protocol
extension LanguagePickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = self.languageList[row]
        return title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentLanguage = self.languageList[row]
    }
}
