//
//  MapRouteModel.swift
//  Feature
//
//  Created by 김준표 on 4/17/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public struct MapRouteModel: Decodable {
    public let routes: [Route]
}

public struct Route: Decodable {
    public let summary: Summary
    public let sections: [Section]
}

public struct Summary: Decodable {
    public let distance: Int      
    public let duration: Int
}

public struct Section: Decodable {
    public let roads: [Road]
}

public struct Road: Decodable {
    public let vertexes: [Double]
}
