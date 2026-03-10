//
//  UIScrollView+Extension.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

extension UIScrollView {

    func updateContentSize() {

        let totalRect = recursiveUnion(in: self)

        contentSize = CGSize(
            width: frame.width,
            height: totalRect.height + 50
        )
    }

    private func recursiveUnion(in view: UIView) -> CGRect {

        var totalRect: CGRect = .zero

        for subview in view.subviews {
            totalRect = totalRect.union(recursiveUnion(in: subview))
        }

        return totalRect.union(view.frame)
    }
}
