//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 준표 on 2/9/26.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "ThirdPartyLib",
    product: .framework,
    packages: [],
    dependencies: [
        .package(product: "RxSwift"),
        .package(product: "SnapKit"),
        .package(product: "Then"),
        .package(product: "Moya"),
        .package(product: "Kingfisher"),
        .package(product: "GAuthSignin"),
        .package(product: "QRCode"),
        .package(product: "QRCodeReader")
    ]
)
