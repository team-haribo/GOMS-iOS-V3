//
//  ReviewPeortREquestDTO.swift
//  Service
//
//  Created by 김준표 on 4/20/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

public struct ReviewReportRequestDTO: Codable {
    public let content: String

    public init(content: String) {
        self.content = content
    }
}
