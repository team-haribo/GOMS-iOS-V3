//
//  MapCardModel.swift
//  Feature
//
//  Created by 김민선 on 2/16/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

struct MapCardModel: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let category: String
    var isFavorite: Bool // true면 GOMS_Primary 색상 하트
    let type: CardType   // .popular, .recommended, .reviewed로 구분
}

enum CardType {
    case popular, recommended, reviewed
}
