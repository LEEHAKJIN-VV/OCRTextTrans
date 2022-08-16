//
//  LanguagePickerViewController.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/15.
//

import Foundation
import UIKit
// MARK: - LangguaguePickerViewController class
class LanguagePickerViewController: UIViewController {
    private var lanPickerView = UIPickerView() // 언어 선택 picker view
    
    private var languageList: [String] = ["한국어","영어","중국어","일본어"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(lanPickerView)
        self.lanPickerView.delegate = self
        
        lanPickerView.backgroundColor = .white
        lanPickerView.setValue(UIColor.black, forKey: "textColor")
    }
    
    override func viewDidLayoutSubviews() {
        lanPickerView.snp.makeConstraints { make in // pickerview가 view controller를 가득 채우게
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - picker view를 구성하는데 필요한 protocol
extension LanguagePickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { // component의 수를 반환
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { // 각 component의 해당하는 row의 수를 반환
        return self.languageList.count
    }
    
    
}

// MARK: - picker view delegate => picker를 선택했을때 관련된 protocol
extension LanguagePickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = self.languageList[row]
        return title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("선택: \(self.languageList[row])")
    }
}

