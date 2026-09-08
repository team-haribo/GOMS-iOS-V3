import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        platform: Platform = .iOS,
        product: Product,
        organizationName: String = "HARIBO",
        packages: [Package] = [],
        deploymentTargets: DeploymentTargets? = .iOS("15.0"),
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        infoPlist: InfoPlist = .default,
        entitlements: Entitlements? = nil,
        xcconfigPath: Path? = nil
    ) -> Project {
        let settings: Settings = .settings(
            base: [:],
            configurations: [
                .debug(name: .debug, settings: entitlements == nil ? [:] : ["APS_ENVIRONMENT": "development"], xcconfig: xcconfigPath),
                .release(name: .release, settings: entitlements == nil ? [:] : ["APS_ENVIRONMENT": "production"], xcconfig: xcconfigPath)
            ],
            defaultSettings: .recommended
        )

        let appTarget = Target.target(
            name: name,
            destinations: [.iPhone],
            product: product,
            bundleId: product == .app
                ? "HARIBO.GOMS-iOS-V2"
                : "HARIBO.\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
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

