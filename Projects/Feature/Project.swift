//
//  Project.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Feature",
    platform: .iOS,
    product: .staticFramework,
    organizationName: "HARIBO",
    deploymentTargets: .iOS("16.0"),
    dependencies: [
        .project(target: "Service", path: .relativeToRoot("Projects/Service")),
        .project(target: "ThirdPartyLib", path: .relativeToRoot("Projects/ThirdPartyLib"))
    ],
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    infoPlist: .default
)
