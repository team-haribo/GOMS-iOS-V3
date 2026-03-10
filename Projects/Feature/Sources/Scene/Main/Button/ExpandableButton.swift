//
//  ExpandableButton.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

class ExpandableButton: UIButton {
    var expandedTouchArea: CGFloat = 20

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let bounds = self.bounds
        let expandedBounds = bounds.insetBy(dx: -expandedTouchArea, dy: -expandedTouchArea)
        return expandedBounds.contains(point)
    }
}
