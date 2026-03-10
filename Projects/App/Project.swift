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
    deploymentTargets: .iOS("16.0"),
    dependencies: [
        .project(target: "Feature", path: .relativeToRoot("Projects/Feature")),
        .project(target: "ThirdPartyLib", path: .relativeToRoot("Projects/ThirdPartyLib"))
    ],
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    infoPlist: .file(path: "Support/Info.plist")
)
