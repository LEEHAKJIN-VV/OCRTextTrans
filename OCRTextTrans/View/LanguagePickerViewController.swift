//
//  LanguagePickerViewController.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/15.
//

import Foundation
import UIKit
import SnapKit
import Combine

// MARK: - LanguagePickerViewController
class LanguagePickerViewController: UIViewController {
    var currentLanguage: String = "한국어"
    
    var languageViewModel = SupportLanguageViewModel() // 지원하는 언어 뷰 모델
    private var languageList: [String] = [] // 지원하는 언어 데이터 목록
    var disposalbleBag = Set<AnyCancellable>() //
    
    private lazy var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.frame = CGRect(x: 0, y: 0, width: ScreenInfo.screenHeight, height: ScreenInfo.screenHeight)
        pv.dataSource = self
        pv.delegate = self
        return pv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(pickerView)
        self.setBingds() // binding
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pickerView.snp.makeConstraints { make in // 제약 설정
            make.center.equalToSuperview()
        }
    }
}
// MARK: - view model
extension LanguagePickerViewController {
    // view model의 language list와 controller의 language list연결
    private func setBingds() {
        self.languageViewModel.$languageList.sink { (updatedList: [String]) in
            self.languageList = updatedList
        }.store(in: &disposalbleBag)
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
