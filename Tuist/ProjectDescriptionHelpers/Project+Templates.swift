//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 준표 on 2/3/26.
//

import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        product: Product,
        organizationName: String = "HARIBO",
        packages: [Package] = [],
        deploymentTargets: DeploymentTargets = .iOS("15.0"),
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        infoPlist: InfoPlist = .default
    ) -> Project {

        let settings: Settings = .settings(
            base: [:],
            configurations: [
                .debug(name: .debug),
                .release(name: .release)
            ],
            defaultSettings: .recommended
        )

        let appTarget: Target = .target(
            name: name,
            destinations: .iOS,
            product: product,
            bundleId: "\(organizationName).\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            dependencies: dependencies
        )

        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            settings: settings,
            targets: [appTarget]
        )
    }
}

