//
//  Dependencies.swift
//  ProjectDescriptionHelpers
//
//  Created by 준표 on 2/9/26.
//

import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: .init(
        
        [
            .remote(
                url: "https://github.com/ReactiveX/RxSwift.git",
                requirement: .upToNextMajor(from: "6.5.0")
            ),
            .remote(
                url: "https://github.com/SnapKit/SnapKit.git",
                requirement: .upToNextMajor(from: "5.0.1")
            ),
            .remote(
                url: "https://github.com/devxoul/Then",
                requirement: .upToNextMajor(from: "2.0.0")
            ),
            .remote(
                url: "https://github.com/Moya/Moya.git",
                requirement: .upToNextMajor(from: "15.0.0")
            ),
            .remote(
                url: "https://github.com/onevcat/Kingfisher.git",
                requirement: .upToNextMajor(from: "7.0.0")
            ),
            .remote(
                url: "https://github.com/GSM-MSG/GAuthSignin-Swift",
                requirement: .upToNextMajor(from: "0.0.3")
            ),
            .remote(
                url: "https://github.com/dmrschmidt/QRCode",
                requirement: .upToNextMajor(from: "1.0.0")
            ),
            .remote(
                url: "https://github.com/yannickl/QRCodeReader.swift.git",
                requirement: .upToNextMajor(from: "10.1.0")
            )
        ],


        products: [
            .product(name: "RxSwift", package: "RxSwift"),
            .product(name: "RxCocoa", package: "RxSwift"),
            .product(name: "RxRelay", package: "RxSwift"),

            .product(name: "SnapKit", package: "SnapKit"),
            .product(name: "Then", package: "Then"),

            .product(name: "Moya", package: "Moya"),
            .product(name: "Alamofire", package: "Alamofire"),

            .product(name: "Kingfisher", package: "Kingfisher"),

 
            .product(name: "GAuthSignin", package: "GAuthSignin")
        ]
    ),
    platforms: [.iOS]
)
