//
//  QRResultType.swift
//  Feature
//
//  Created by 김준표 on 2/25/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import UIKit

enum QRResultType {
    case outing
    case comeback
    case late
    case qrError
    case blacklist
}

extension QRResultType {
    var image: UIImage {
        switch self {
        case .outing:
            return .image.comeback.image
        case .comeback:
            return .image.outingCheck.image
        case .late:
            return .image.banned.image
        case .qrError:
            return .image.outingFailed.image
        case .blacklist:
            return .image.banned.image
        }
    }
    
    
    var mainText: String {
        switch self {
        case .outing:
            return "외출을 시작해 봐요!"
        case .comeback:
            return "복귀에 성공했어요!"
        case .late:
            return "지각하셨네요.."
        case .qrError:
            return "외출에 실패했어요.."
        case .blacklist:
            return "외출하실 수 없어요"
        }
    }
    
    var descriptionText: String {
        switch self {
        case .outing:
            return "지금부터 외출하실 수 있어요.\n7시 25분 이전에 복귀해 주세요!"
        case .comeback:
            return "제 때 복귀하셨군요!\n다음 외출제 때 또 만나요!"
        case .late:
            return "앞으로 1주간 외출을 하실 수 없어요.\n다음엔 늦지 마세요!"
        case .qrError:
            return "예기치 못한 오류가 발생했어요.\n다시 시도해 주세요!"
        case .blacklist:
            return "외출 금지 상태에서는 외출이 불가능합니다.\n다음 외출제를 이용해 주세요."
        }
    }
}
