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
        testSources: SourceFilesList? = nil
    ) -> Project {
        let settings: Settings = .settings(
            base: [:],
            configurations: [
                .debug(name: .debug),
                .release(name: .release)
            ],
            defaultSettings: .recommended
        )

        let appTarget = Target.target(
            name: name,
            destinations: [.iPhone, .iPad],
            product: product,
            bundleId: product == .app
                ? "HARIBO.GOMS-iOS-V2"
                : "HARIBO.\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            dependencies: dependencies
        )

        var targets: [Target] = [appTarget]

        if let testSources = testSources {
            let testTarget = Target.target(
                name: "\(name)Tests",
                destinations: [.iPhone, .iPad],
                product: .unitTests,
                bundleId: "HARIBO.\(name)Tests",
                deploymentTargets: deploymentTargets,
                infoPlist: .default,
                sources: testSources,
                dependencies: [
                    .target(name: name)
                ]
            )
            targets.append(testTarget)
        }

        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            settings: settings,
            targets: targets
        )
    }
}

