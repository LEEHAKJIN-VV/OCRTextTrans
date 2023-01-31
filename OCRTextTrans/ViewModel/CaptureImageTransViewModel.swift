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
class CaptureImageTransViewModel {
    private var language: String = "한국어" // 현재 언어
    private var translator: Translator! // 번역기
    @Published var translatedText: String = "" // 번역된 텍스트

    init(text: String, sourceLan: String, targetLan: String) { // 생성자
        self.createOptions(text: text, sourceLanguage: sourceLan, targetLanguage: targetLan)
    }
    private func createOptions(text: String, sourceLanguage: String, targetLanguage: String) { // options 생성
        let sourceLanguageType: TranslateLanguage = LanguageModel.getTranslateType(inputIanguage: sourceLanguage)
        let targetLanguageType: TranslateLanguage = LanguageModel.getTranslateType(inputIanguage: targetLanguage)
        
        let options = TranslatorOptions(sourceLanguage: sourceLanguageType, targetLanguage: targetLanguageType)
        
        self.translator = Translator.translator(options: options) // 번역기 업데이트
        self.translate(text: text) // 번역
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
                self.translatedText = translatedText // data binding
            }
        }
    }
    private func model(forLanguage: TranslateLanguage) -> TranslateRemoteModel { // 모델을 얻는 함수
        return TranslateRemoteModel.translateRemoteModel(language: forLanguage)
    }
    
    private func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool { // 해당 언어를 사용하는 모델이 디바이스에 로드되었는 지 확인하는 함수
        let model = self.model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        return modelManager.isModelDownloaded(model)
    }
    
    func handleDownloadDeleteModel(text: String, sourceLan: String, targetLan: String) { // 모델의 다운로드와 삭제를 담당하는 함수
        let language: TranslateLanguage = LanguageModel.getTranslateType(inputIanguage: targetLan)
        
        let model = self.model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue)! // "한국어" -> Korean "중국어" -> Chinese
        print("languageName: \(languageName)")
        
        if modelManager.isModelDownloaded(model) { // model이 존재하는 경우 delete
            print("Deleting \(languageName)")
            modelManager.deleteDownloadedModel(model) { (error) in
                print("Deleted \(languageName)")
            }
        } else {
            print("model download \(languageName)")
            let conditions = ModelDownloadConditions(
                allowsCellularAccess: false,
                allowsBackgroundDownloading: true)
            modelManager.download(model, conditions: conditions)
        }
        self.createOptions(text:text,sourceLanguage: sourceLan, targetLanguage: targetLan)
    }
}
