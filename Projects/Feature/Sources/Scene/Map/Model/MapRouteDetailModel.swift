//
//  MapRouteDetailModel.swift
//  Feature
//
//  Created by 김민선 on 3/15/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

public enum RouteTurnType {
    case start
    case straight
    case left
    case right
    case end
    
    var iconName: String {
        switch self {
        case .start: return "ic_route_location_pin"
        case .straight: return "ic_route_straight"
        case .left: return "ic_route_turn_left"
        case .right: return "ic_route_turn_right"
        case .end: return "ic_route_location_pin"
        }
    }
}

// 빌드 에러 수정을 위한 모델 정의
struct RouteStepModel {
    let turnType: RouteTurnType
    let title: String
    let description: String
    
    var iconName: String {
        return turnType.iconName
    }
}
