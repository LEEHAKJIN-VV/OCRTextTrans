//
//  OCRModel.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/19.
//

import Foundation
import UIKit
import MLKit
import Combine

// MARK: - 이미지에서 텍스트를 인식하는 모델 -> 번역이 아닌 텍스트만 인식함
class OCRModel {
    private var ocrImage: UIImage // 텍스트를 추출할 이미지
    private var recognitionLanguage: String? // 이미지에서 인식할 글자
    private var languageModel: LanguageModel = LanguageModel() // 언어 모델
    private var languagetype: LanguageType // 언어의 region type
    
    @Published var recognizeText: String = "" // 이미지에서 인식한 텍스트: published
    var disposalbleBag = Set<AnyCancellable>() 
    
    init(extractImg: UIImage, recLanguage: String) { // 생성자
        self.ocrImage = extractImg
        self.languagetype = languageModel.getLanguageRegion(language: recLanguage) // 인식해야할 언어 타입을 확인
        self.startOCR() // OCR 시작
    }
    private func startOCR() { // Start OCR
        switch self.languagetype { // 언어의 region에 따른 텍스트 인식기 생성
        case .latin:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: TextRecognizerOptions()))
        case .devanagari:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: DevanagariTextRecognizerOptions()))
        case .japanese:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: JapaneseTextRecognizerOptions()))
        case .chinese:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: ChineseTextRecognizerOptions()))
        case .korean:
            self.recoginzeText(textRecognizer: TextRecognizer.textRecognizer(options: KoreanTextRecognizerOptions()))
        }
    }
    private func recoginzeText(textRecognizer: TextRecognizer) { // 이미지내 텍스트 인식
        let inputImage = VisionImage(image: self.ocrImage)
        inputImage.orientation = self.ocrImage.imageOrientation // 이미지 방향 설정
        textRecognizer.process(inputImage) { result, error in
            guard error == nil, let resultText = result else {  // Error Handling
                return
            }
            self.recognizeText = resultText.text // 인식한 텍스트
        }
    }
}


