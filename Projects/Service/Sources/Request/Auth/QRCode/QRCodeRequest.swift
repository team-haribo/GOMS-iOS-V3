//
//  QRCodeRequest.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct QRCodeRequest: Codable {
    public var outingUUID: UUID
    
    public init(outingUUID: UUID) {
        self.outingUUID = outingUUID
    }
}
