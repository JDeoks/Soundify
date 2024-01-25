//
//  ConfigManager.swift
//  Soundify
//
//  Created by JDeoks on 1/26/24.
//

import Foundation
import Firebase
import FirebaseRemoteConfig
import RxSwift

class ConfigManager {
    
    static let shared = ConfigManager()
    
    let remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    /// 기본 점검메시지 isEmpty일경우 점검중 아님
    let defaultMaintenanceNotice: String = ""
    let defaultGreetingMessage: String = ""
    let defaultMinimumVersion: String = "1.0"

    let fetchRemoteConfigDone = PublishSubject<Void>()

    private init() {
        print("\(type(of: self)) - \(#function)")

        let settings = RemoteConfigSettings()
        // 앱 켤때마다 실행
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
    
    /// Firebase RemoteConfig, UserDefaults 에 사용하는 키
    enum RemoteConfigKey: String {
        case minimumVersion = "minimumVersion"
        case maintenanceNotice = "maintenanceNotice"
//        case greetingMessage = "greetingMessage"
    }
    
    /// Config 서버값을 fetch해서 로컬에 저장하는 함수
    func fetchRemoteConfig() {
        print("\(type(of: self)) - \(#function)")
        
        remoteConfig.fetch { (status, error) in
            if status != .success {
                print("실패 status: \(status)")
                self.fetchRemoteConfigDone.onNext(())
                return
            }
            if let error = error {
                print(error.localizedDescription)
                self.fetchRemoteConfigDone.onNext(())
                return
            }
            self.remoteConfig.activate { _, _ in
                self.setRemoteConfigToLocal {
                    print("fetchRemoteConfigDone")
                    self.fetchRemoteConfigDone.onNext(())
                }
            }
        }
    }
    
    /// 로컬에 Config 정보 저장
    func setRemoteConfigToLocal(completion: @escaping () -> Void) {
        print("\(type(of: self)) - \(#function)")
        
        // minimumVersion
        if let minimumVersion: String = self.remoteConfig.configValue(forKey: RemoteConfigKey.minimumVersion.rawValue).stringValue {
            print("minimumVersion:",minimumVersion)
            UserDefaults.standard.set(minimumVersion, forKey: RemoteConfigKey.minimumVersion.rawValue)
        } else {
            print("forKey: RemoteConfig에 minimumVersion 없음")
        }
        
        // maintenanceNotice
        if let maintenanceNotice: String = self.remoteConfig.configValue(forKey: RemoteConfigKey.maintenanceNotice.rawValue).stringValue {
            print("maintenanceNotice:",maintenanceNotice)
            UserDefaults.standard.set(maintenanceNotice, forKey: RemoteConfigKey.maintenanceNotice.rawValue)
        } else {
            print("forKey: RemoteConfig에 maintenanceNotice 없음")
        }

        completion()
    }
    
    /// 로컬 Config에서 최소버전 만족 여부 확인하는 함수
    func isMinimumVersionSatisfied() -> Bool {
        print("\(type(of: self)) - \(#function)")

        let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1"
        let minimumVersion = getMinimumVersionFromLocal()
        print("currentAppVersion: ", currentAppVersion, "minimumVersion: ", minimumVersion)
        print(currentAppVersion.compare(minimumVersion, options: .numeric) != .orderedAscending)
        return currentAppVersion.compare(minimumVersion, options: .numeric) != .orderedAscending
    }
    
    /// 로컬 Config에서 최소버전 String 가져오는 함수
    func getMinimumVersionFromLocal() -> String {
        print("\(type(of: self)) - \(#function)")

        guard let minimumVersion = UserDefaults.standard.string(forKey: RemoteConfigKey.minimumVersion.rawValue) else {
            print("forKey: minimumVersion 없음. 기본 값 사용")
            return defaultMinimumVersion
        }
        return minimumVersion
    }
    
    /// 로컬 Config에서 점검정보 가져오는 함수
    func getMaintenanceStateFromLocal() -> String {
        print("\(type(of: self)) - \(#function)")

        guard let maintenanceNotice = UserDefaults.standard.string(forKey: RemoteConfigKey.maintenanceNotice.rawValue) else {
            print("forKey: maintenanceNotice 없음. 기본 값 사용")
            return defaultMaintenanceNotice
        }
        return maintenanceNotice
    }
    
}
