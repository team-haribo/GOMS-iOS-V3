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
    public lazy var accessToken = "Bearer " + (keyChain.read(key: Const.KeyChainKey.accessToken) ?? "")
    public var isLogin: Bool {
        return accessToken != nil
    }
    
    public init() {}
}
