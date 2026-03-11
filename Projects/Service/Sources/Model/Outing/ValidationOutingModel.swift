//
//  ValidationOutingModel.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct ValidationOutingModel: Codable {
    let data: ValidationOutingResponse
}

public struct ValidationOutingResponse: Codable {
    public let isOuting: Bool
}
