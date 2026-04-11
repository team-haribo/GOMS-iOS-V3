//
//  StudentCouncilRequestModel.swift
//  Service
//
//  Created by 김준표 on 4/11/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct StudentCouncilRequestModel {
    
    // MARK: - 권한 변경
    public struct ChangeRole: Encodable {
        public let role: String
        
        public init(role: Authority) {
            self.role = role.rawValue
        }
    }
    
    // MARK: - 외출 허용 상태 변경
    public struct OutingAllowed: Encodable {
        public let status: String
        
        public init(status: OutingStatus) {
            self.status = status.rawValue
        }
    }
}
