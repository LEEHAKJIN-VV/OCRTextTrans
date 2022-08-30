//
//  CaptureImageTransViewModel.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/30.
//

import Foundation
import MLKitTranslate
import Combine


// MARK: - 인식한 텍스트를 번역시키는 view model -> CaptureImageTransView와 연결
/// languagemodel 수정 필요, model 관련 수정 필요
class CaptureImageTransViewModel {
    private var languageModel: LanguageModel = LanguageModel() // language model
    private var language: String = "한국어" // 현재 언어
    private var translator: Translator! //
    @Published var translatedText: String = "" // 번역된 텍스트
    
    init(text: String, sourceLan: String, targetLan: String) { // 생성자
        print("추출된 언어: \(text)")
        let sourceLanguage: TranslateLanguage = languageModel.getTranslateType(language: sourceLan)
        let targetLanguage: TranslateLanguage = languageModel.getTranslateType(language: targetLan)
        let options = TranslatorOptions(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        
        self.translator = Translator.translator(options: options)
        
        translate(text: text) // 번역
    }
    private func translate(text: String) { // 번역 시작
        let translatorDownloading: Translator = self.translator!
        translatorDownloading.downloadModelIfNeeded { (error) in
            guard error == nil else {
                return
            }
            translatorDownloading.translate(text) { (resultText ,error) in
                guard error == nil, let translatedText = resultText else {
                    return
                }
                self.translatedText = translatedText // view binding
            }
        }
    }
}
