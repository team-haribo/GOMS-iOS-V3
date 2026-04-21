//
//  IntrinsicTableView.swift
//  Feature
//
//  Created by 김민선 on 3/22/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

public final class IntrinsicTableView: UITableView {
    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            superview?.layoutIfNeeded()
        }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
