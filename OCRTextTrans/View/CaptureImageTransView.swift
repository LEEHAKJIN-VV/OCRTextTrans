//
//  CaptureImageTransView.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/13.
//

import Foundation
import UIKit
import SnapKit

// 카메로라 찍은 이미지에서 텍스트를 추출하여 번역된 결과를 보여주는 뷰 컨트롤러
class CaptureImageTransView: UIViewController {
    private let screenWidth = UIScreen.main.bounds.width - 20
    private let screenHeight = UIScreen.main.bounds.height / 3
    
    private var recognitionLanguage: String = "" // 인식한 언어
    private var transLanguage: String = "" // 번역할 언어

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
    init(image: UIImage, recLanguage: String, transLanguage: String) { // recLanguage: 탐지한 언어, transLanguage: 번역할 언어
        super.init(nibName: nil, bundle: nil)
        self.recognitionLanguage = recLanguage // 탐지할 언어
        self.transLanguage = transLanguage // 번역할 언어 변경
        print(recLanguage, transLanguage)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let languageVC = LanguagePickerViewController() // 언어선택 피커뷰 생성
        languageVC.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        
        let alert = UIAlertController(title: "언어 선택", message: "", preferredStyle: .actionSheet) // 피커뷰를 담을 alert 컨트롤러 생성
//        아이패드 코드
//        alert.popoverPresentationController?.sourceView = languageButton
//        alert.popoverPresentationController?.sourceRect = languageButton.bounds
        
        alert.setValue(languageVC, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { (_) in
            // do something
        })
        alert.addAction(UIAlertAction(title: "선택", style: .default) { (_) in
            self.transLanguage = languageVC.currentLanguage
            print("현재 선택언어: \(self.transLanguage)")
        })
        self.present(alert, animated: true)
    }
}

// MARK: - Swift UI preview
//#if DEBUG
//import SwiftUI
//
//struct CaptureImageTransViewRepresentable: UIViewControllerRepresentable {
//    // update
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//
//    }
//    @available(iOS 13.0, *)
//    func makeUIViewController(context: Context) -> UIViewController {
//        CaptureImageTransView()
//
//    }
//    @available(iOS 13.0, *)
//    struct ViewController_Previews: PreviewProvider {
//        static var previews: some View {
//            if #available(iOS 15.0, *) {
//                CaptureImageTransViewRepresentable()
//                    .previewInterfaceOrientation(.portrait)
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//    }
//}

//#endif
