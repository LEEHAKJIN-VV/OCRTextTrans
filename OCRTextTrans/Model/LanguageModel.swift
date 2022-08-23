//
//  LanguageModel.swift
//  OCRTextTrans
//
//  Created by 이학진 on 2022/08/19.
//

import Foundation

// MARK: - 언어 모델
struct LanguageModel {
    // 언어 리스트
    private var languageList: [String] = [
        "아프리카어","알바니아어","카탈루냐어","중국어","크로아티아어","체코어","덴마크어","네덜란드어","영어","에스토니아어","필리핀어","핀란드어","프랑스어","독일어","힌디어","헝가리어","아이슬란드어","인도네시아어","이탈리아어","일본어","한국어","라트비아어","리투아니아어","말레이어","마라티아어","노르웨이어","폴란드어","포르투칼어","루마니아어","세르비아어","슬로바키아어","슬로베니아어","스페인어","스웨덴어","터키어","베트남어"
    ]
    init() {
        self.languageList.sort() // 한글순으로 언어 정렬
    }
    
    // 지원하는 언어를 반환
    func getLanguageList() -> [String] { //
        return self.languageList
    }
    func getLanguageRegion(language: String) -> LanguageType{ // 각 언어가 해당하는 region을 반환함 (ex: 라틴어: 영어)
        switch language {
        case "아프리카어", "알바니아어","영어", "독일어":
            return .latin
        case "인도어":
            return .devanagari
        case "중국어":
            return .chinese
        case "일본어":
            return .japanese
        case "한국어":
            return .korean
        default: // 아무 언어도 선택안하고 번역버튼 누르면 여기서 오류발생 수정예정
            return .latin
            //fatalError()
        }
    }
}
