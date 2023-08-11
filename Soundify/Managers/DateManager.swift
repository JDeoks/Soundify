//
//  DateManager.swift
//  Soundify
//
//  Created by 서정덕 on 2023/08/09.
//

import Foundation
import SwiftDate

class DateManager {
    
    static let shared = DateManager()  // 싱글톤 인스턴스
    
    private init() {}  // 외부에서 인스턴스 생성 방지
    
    // 현재 사용자의 지역에 맞는 날짜와 시간 문자열 반환
    func getCurrentLocalizedDateTimeString() -> String {
        
        let userRegion = Region.current
        let now = DateInRegion(region: userRegion)
        let dateFormat = "yyyy-MM-dd HH-mm"
        return now.toFormat(dateFormat)
    }
    
    func getNowTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?

        return dateFormatter.string(from: now)
    }
}
