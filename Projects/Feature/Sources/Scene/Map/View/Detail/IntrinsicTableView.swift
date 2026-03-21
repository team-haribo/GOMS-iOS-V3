//
//  IntrinsicTableView..swift
//  Feature
//
//  Created by 김민선 on 3/22/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

// 콘텐츠 크기에 맞춰 높이가 자동 조절되는 커스텀 테이블뷰
public final class IntrinsicTableView: UITableView {
    public override var contentSize: CGSize {
        didSet {
            // 콘텐츠 사이즈가 변경될 때마다 레이아웃을 다시 계산
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
