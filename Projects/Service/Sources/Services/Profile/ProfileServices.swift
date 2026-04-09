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
    case update(authorization: String, imageData: Data)
    case delete(authorization: String)
}
struct ProfileImageResponse: Codable {
    let imageUrl: String
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
            return "/api/v3/member/profile"
        case .update:
            return "/api/v3/member/profile-image"
        case .delete:
            return "/api/v3/member/profile-image"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getProfile:
            return .get
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
        case let .update(_, imageData):
            print("imageData size:", imageData.count)
            let formData = MultipartFormData(
                provider: .data(imageData),
                name: "image",
                fileName: "profile.jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([formData])
        case .delete:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .getProfile(let authorization),
             .update(let authorization, _),
             .delete(let authorization):
            return [
                "Authorization": authorization
            ]
        }
    }
}
