//
//  CaptureImageTransView.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/13.
//

import Foundation
import UIKit
import SnapKit

class CaptureImageTransView: UIViewController {
    private let screenWidth = UIScreen.main.bounds.width - 20
    private let screenHeight = UIScreen.main.bounds.height / 3
    private var languageList: [String] = ["한국어","영어","중국어","일본어"] // 임시 데이터

    // UIView object
    private lazy var textContainerView: UIView = { // 번역 화면의 컨테이너 뷰
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var transTextView: UITextView = { // 추출된 텍스트를 보여주는 버튼
        let textview = UITextView()
        textview.font = UIFont.preferredFont(forTextStyle: .subheadline) // textview의 font 크기 설정
        textview.adjustsFontForContentSizeCategory = true // text의 dynamic type 설정
        textview.textColor = .black // 글자 색
        textview.text = StringDescription.TransField.textholder.rawValue // 글자
        textview.textContainerInset = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32) // uitextview의 text 여백 설정
        textview.backgroundColor = .gray // 배경색
        textview.isEditable = false // 편집 여부
        return textview
    }()
    private lazy var optionStackView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .horizontal // 수평 스택 뷰
        stackview.alignment = .fill // axis의 반대를 채움
        stackview.distribution = .equalSpacing
        return stackview
    }()
    private lazy var copyButton: UIButton = { // 번역된 텍스트를 복하는 버튼
        let button = UIButton()
        button.setImage(UIImage(systemName: "doc.text"), for: .normal)
        button.tintColor = .black
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    private lazy var languageButton: UIButton = { // 언어를 선택하는 버튼
        let button = UIButton()
        button.setImage(UIImage(systemName: "globe"), for: .normal)
        button.tintColor = .black
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private lazy var saveButton: UIButton = { // 텍스트를 저장하는 버튼
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.tintColor = .black
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        self.view.addSubview(textContainerView) // 번역될 텍스트뷰를 담을 컨테이너 뷰
        self.textContainerView.addSubview(optionStackView) // stackview 등록
        self.textContainerView.addSubview(transTextView) // 번역할 텍스트를 보여주는 뷰
        self.optionStackView.addArrangedSubview(copyButton) // 복사 버튼
        self.optionStackView.addArrangedSubview(languageButton) // 언어 버튼
        self.optionStackView.addArrangedSubview(saveButton) // 저장 버튼
        self.navigationItem.title = "번역 화면"
        self.navigationController?.navigationBar.tintColor = .white
        // 액션메소드 등록
        self.languageButton.addTarget(self, action: #selector(clickLanBtn(_:)), for: .touchUpInside)
        self.copyButton.addTarget(self, action: #selector(clickCopyBtn(_:)), for: .touchUpInside)
        self.saveButton.addTarget(self, action: #selector(clickSaveBtn(_:)), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        // 상세 제약은 수정 예정
        textContainerView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        optionStackView.snp.makeConstraints { make in
            make.height.equalTo(self.screenHeight/7)
            make.leading.trailing.equalToSuperview().inset(32)
            make.top.equalToSuperview().offset(16)
        }
        copyButton.snp.makeConstraints { make in
            make.width.equalTo(self.screenWidth/10)
        }
        saveButton.snp.makeConstraints { make in
            make.width.equalTo(self.screenWidth/10)
        }
        languageButton.snp.makeConstraints { make in
            make.width.equalTo(self.screenWidth/10)
        }
        transTextView.snp.makeConstraints { make in
            make.top.equalTo(self.optionStackView.snp.bottom).offset(16)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    @objc func clickCopyBtn(_ sender: Any) { // 현재 텍스트를 클립보드에 저장하는 버튼
        UIPasteboard.general.string = self.transTextView.text // 클립보드에 현재 텍스트뷰의 텍스트 내용 저장
    }
    @objc func clickSaveBtn(_ sender: Any) { // 현재 번역한 텍스트를 저장하는 버튼
        
    }
    
    @objc func clickLanBtn(_ sender: Any) { // 언어를 선택하는 버튼
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        vc.view.addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let alert = UIAlertController(title: "언어 선택", message: "", preferredStyle: .actionSheet)
        // 아이패드에서 사용되는 코드
//        alert.popoverPresentationController?.sourceView = languageButton
//        alert.popoverPresentationController?.sourceRect = languageButton.bounds
        
        alert.setValue(vc, forKey: "contentViewController") // alert에 contentViewController 설정
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { (_) in
            
        })
        alert.addAction(UIAlertAction(title: "선택", style: .default) { (_) in
            print("현재 선택 언어: \(pickerView.selectedRow(inComponent: 0))")
        })
        self.present(alert, animated: true)
    }
}

// MARK: - picker view를 구성하는데 필요한 protocol
extension CaptureImageTransView: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.languageList.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { // component의 수를 반환
        return 1
    }
}

// MARK: - picker view delegate => picker를 선택했을때 관련된 protocol
extension CaptureImageTransView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = self.languageList[row]
        return title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("선택: \(self.languageList[row])")
    }
}

// MARK: - Swift UI preview
#if DEBUG
import SwiftUI

struct CaptureImageTransViewRepresentable: UIViewControllerRepresentable {
    // update
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    @available(iOS 13.0, *)
    func makeUIViewController(context: Context) -> UIViewController {
        CaptureImageTransView()
        
    }
    @available(iOS 13.0, *)
    struct ViewController_Previews: PreviewProvider {
        static var previews: some View {
            if #available(iOS 15.0, *) {
                CaptureImageTransViewRepresentable()
                    .previewInterfaceOrientation(.portrait)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

#endif
