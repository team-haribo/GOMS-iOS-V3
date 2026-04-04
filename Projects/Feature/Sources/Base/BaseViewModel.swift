//
//  BaseViewModel.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Moya
import Service
import Foundation

public class BaseViewModel {
    public static let shared = BaseViewModel()
    
    public let keyChain = KeyChain()
    let gomsRefreshToken = GOMSRefreshToken.shared
    
   
    public var accessToken: String {
        guard let token = keyChain.read(key: Const.KeyChainKey.accessToken),
              !token.isEmpty else {
            return ""
        }
        return "Bearer \(token)"
    }
    
    public var isLogin: Bool {
        guard let token = keyChain.read(key: Const.KeyChainKey.accessToken) else {
            return false
        }
        return !token.isEmpty
    }
    
    public init() {}
}
