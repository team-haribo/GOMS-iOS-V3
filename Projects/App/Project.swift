//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 준표 on 2/3/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "GOMS-iOS-V3",
    platform: .iOS,
    product: .app,
    organizationName: "HARIBO",

    packages: [ 
        .remote(
            url: "https://github.com/kakao-mapsSDK/KakaoMapsSDK-SPM",
            requirement: .upToNextMajor(from: "2.10.0")
        )
    ],

    deploymentTargets: .iOS("16.0"),

    dependencies: [
        .project(target: "Feature", path: .relativeToRoot("Projects/Feature")),
        .project(target: "ThirdPartyLib", path: .relativeToRoot("Projects/ThirdPartyLib")),
        .package(product: "KakaoMapsSDK-SPM")
    ],

    sources: ["Sources/**"],
    resources: ["Resources/**"],
    infoPlist: .file(path: "Support/Info.plist"),
    entitlements: .file(path: "Support/GOMS-iOS-V3.entitlements")
)
