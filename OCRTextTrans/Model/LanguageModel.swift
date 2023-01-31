//
//  LanguageModel.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/19.
//

import Foundation
import MLKitTranslate
import SnapKit

// MARK: - 언어 모델
// LanguageModel 리팩토링 필요
/// Text Recognition, translate text -> BCP - 47 Code
struct LanguageModel {
    // 언어 리스트
    private var languageList: [String] = [
        "아프리카어","알바니아어","카탈루냐어","중국어","크로아티아어","체코어","덴마크어","네덜란드어","영어","에스토니아어","필리핀어","핀란드어","프랑스어","독일어","힌디어","헝가리어","아이슬란드어","인도네시아어","이탈리아어","일본어","한국어","라트비아어","리투아니아어","말레이어","마라티아어","노르웨이어","폴란드어","포르투칼어","루마니아어","세르비아어","슬로바키아어","슬로베니아어","스페인어","스웨덴어","터키어","베트남어"
    ]
    
    static var allLanguages = Array(TranslateLanguage.allLanguages())
    //[korea Language name: bcp-47 code]
    static var languageCode: [String:String] = [
        "아프리칸스어":"af", "알바니아어":"sq", "카탈루냐어":"ca", "중국어":"zh", "크로아티아어":"hr",
        "체코어":"cs", "덴마크어":"da", "네덜란드어":"nl", "영어":"en", "에스토니아어":"et",
        "필리핀어":"fil", "핀란드어":"fi", "프랑스어":"fr", "독일어":"de", "힌디어":"hi",
        "헝가리어":"hu", "아이슬란드어":"is", "인도네시아어":"id", "이탈리아어":"id", "일본어":"ja",
        "한국어":"ko", "라트비아어":"lv", "리투아니아":"lt", "말레이어":"ms", "마라티아어":"mr",
        "네팔어":"ne", "노르웨이어":"no", "폴란드어":"pl", "포르투칼어":"pt", "루마니아어":"ro",
        "세르비아어":"sr-Latn", "슬로바키아어":"sk", "슬로베니아어":"sl", "스페인어":"es", "스웨덴어":"sv",
        "터키어":"tr", "베트남어":"vi", "아랍어":"ar", "벨라루스어":"be", "불가리아어":"bg", "벵골어":"bn",
        "웨일스어":"cy" ,"그리스어":"el" ,"에스페란토어":"eo", "페르시아어":"fa", "아일랜드어":"ga", "갈리시아어":"gl",
        "구자라트어":"gu", "히브리어":"he", "아이티":"ht", "조지아어":"ka", "마케도니아어":"mk", "몰타어":"mt",
        "러시아어":"ru", "스와힐리어":"sw", "타밀어":"ta", "텔루구어":"te", "태국어":"th", "타갈로그어":"tl",
        "우크라이나어":"uk", "우르두어":"ur"
    ]
    init() {
        self.languageList.sort() // 한글순으로 언어 정렬
    }
    
    // 지원하는 언어를 반환
    func getLanguageList() -> [String] { //
        return self.languageList
    }
    static func getLanguageRegion(language: String) -> LanguageType { // 각 언어가 해당하는 region을 반환함 (ex: 라틴어: 영어)
        switch language {
        case "인도어","마티아어","네팔어":
            return .devanagari
        case "중국어":
            return .chinese
        case "일본어":
            return .japanese
        case "한국어":
            return .korean
        default: // 위 언어 빼고는 전부다 latin region
            return .latin
        }
    }
    
    static func getTranslateType(inputIanguage: String) -> TranslateLanguage { // 번역 언어 인식 타입 반환
        guard let bcfCode = languageCode[inputIanguage] else {
            return .korean // default
        }
        
        for language in allLanguages {
            if language.rawValue == bcfCode {
                return language
            }
        }
        return .korean // default
    }
}

