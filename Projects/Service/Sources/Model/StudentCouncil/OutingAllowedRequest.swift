//
//  OutingAllowedRequest.swift
//  Service
//
//  Created by 김준표 on 4/11/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct OutingAllowedRequest: Encodable {
    public let status: String
    
    public init(status: OutingStatus) {
        self.status = status.rawValue
    }
}
