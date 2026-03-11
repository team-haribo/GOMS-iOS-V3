//
//  ProfileServices.swift
//  Service
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation
import Moya

public enum ProfileServices {
    case getProfile(authorization: String)
    case submit(authorization: String, imageData: Data)
    case update(authorization: String, imageData: Data)
    case delete(authorization: String)
}
struct ProfileImageResponse: Codable {
    let file: Data
}

extension ProfileServices: TargetType {
    public var baseURL: URL {
        guard let urlString = Bundle.main.infoDictionary?["SchoolBaseURL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("ProfileAPIㅣURL을 불러올 수 없습니다.")
        }
        return url
    }

    public var path: String {
        switch self {
        case .getProfile:
            return "/account/profile"
        case .submit:
            return "/account/image"
        case .update:
            return "/account/image"
        case .delete:
            return "/account"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getProfile:
            return .get
        case .submit:
            return .post
        case .update:
            return .patch
        case .delete:
            return .delete
        }
    }
    
    public var task: Task {
        switch self {
        case .getProfile:
            return .requestPlain
        case let .submit(authorization, imageData),
             let .update(authorization, imageData):
            let formData = MultipartFormData(provider: .data(imageData), name: "File", fileName: "profile_image.jpg", mimeType: "image/jpeg")
            return .uploadMultipart([formData])
        case let .delete(authorization):
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .getProfile(let authorization):
            return ["Content-Type": "application/json", "Authorization": authorization]
        default:
            return ["Content-Type": "application/json"]
        }
    }
}
