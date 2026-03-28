//
//  SendAuthCodeRequest.swift
//  Service
//
//  Created by 김준표 on 3/27/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct SendAuthCodeRequest: Codable {
<<<<<<< HEAD
    var email: String
    var purpose: String
    
=======
    public let email: String
    public let purpose: String

>>>>>>> 280c893 (💄- fix :: [#97] email-verification API 500 에러 해결 및 요청 로깅 추가)
    public init(email: String, purpose: String) {
        self.email = email
        self.purpose = purpose
    }
}
