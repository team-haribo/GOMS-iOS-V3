//
//  QRCodeViewModel.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import UIKit
import Moya
import Service
import CoreImage.CIFilterBuiltins

public final class QRCodeViewModel: BaseViewModel {
    private let studentCouncilProvider = MoyaProvider<StudentCouncilServices>()
    private let outingProvider = MoyaProvider<OutingServices>()
    private let profileViewModel = ProfileViewModel()
    
    public var outingUUID: UUID = UUID()
    private var isRequesting: Bool = false

    func outing(completion: @escaping (String) -> Void) {
        guard !isRequesting else {
            print("이미 외출 요청이 진행 중입니다.")
            return
        }
        
        isRequesting = true
        outingProvider.request(.outing(outingUUID: outingUUID, authorization: accessToken)) { response in
            switch response {
            case .success(let result):
                let statusCode = result.statusCode
                switch statusCode {
                case 204:
                    self.profileViewModel.loadProfileInfo { success, authority in
                        if success {
                            if let profileInfo = self.profileViewModel.profileInfo {
                                if profileInfo.isOuting == true {
                                    completion("outing")
                                } else if profileInfo.isOuting == false {
                                    completion("comeback")
                                }
                            } else {
                                print("Profile info is nil")
                            }
                        } else {
                            print("Failed to load profile info")
                        }
                    }
                case 400:
                    self.profileViewModel.loadProfileInfo { success, authority in
                        if success {
                            if let profileInfo = self.profileViewModel.profileInfo {
                                if profileInfo.isBlackList == true {
                                    completion("blackList")
                                } else {
                                    completion("uuidError")
                                 }
                            } else {
                                print("Profile info is nil")
                            }
                        } else {
                            print("Failed to load profile info")
                        }
                    }
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 500:
                    print("SERVER ERROR")
                default:
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func makeQR(completion: @escaping (Bool) -> Void) {
        studentCouncilProvider.request(.makeQRCode(authorization: accessToken)) { response  in
            switch response {
            case .success(let result):
                let statusCode = result.statusCode
                switch statusCode {
                case 200:
                    do {
                        let responseJSON = try result.mapJSON() as? [String: Any]
                        if let outingUUIDString = responseJSON?["outingUUID"] as? String,
                           let outingUUID = UUID(uuidString: outingUUIDString) {
                            self.outingUUID = outingUUID
                            completion(true)
                        } else {
                            print("outingUUID를 가져올 수 없습니다.")
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                case 401:
                    self.gomsRefreshToken.tokenReissuance(){ success in}
                case 403:
                    print("학생회 계정이 아닌데 요청할 경우")
                    completion(false)
                case 500:
                    print("SERVER ERROR")
                    completion(false)
                default:
                    print(result)
                }
            case .failure(let err):
                print(err.localizedDescription)
                completion(false)
            }
        }
    }
}

