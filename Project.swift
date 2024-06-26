import ProjectDescription

/// Name
let appName = "WhatToDo"
let testName = "WhatToDoTests"

/// ID
let bundleAppID = "com.Junwoo.Jununu.WhatToDo"
let bundleTestID = "com.Junwoo.Jununu.WhatToDoTests"

/// File Path
let sources: SourceFilesList = ["APP/Sources/**"]
let resources: ResourceFileElements = ["APP/Resources/**", "APP/Deprecated/**", "Configs/**"]
let tests: SourceFilesList = ["APP/Tests/**"]

/// Info.plist
let info: InfoPlist = "Info/Info.plist"

/// Config
let config = "Configs/WhatToDo.xcconfig"

/// Version
let version = "16.0"

enum Settings: ConfigurationName {
    case debug = "Debug"
    case release = "Release"
}

let project = Project(
    name: appName,
    targets: [
        .target(
            name: appName,
            destinations: .iOS,
            product: .app,
            bundleId: bundleAppID,
            deploymentTargets: .iOS(version),
            infoPlist: info,
            sources: sources,
            resources: resources,
            dependencies: [
                .external(name: "RxDataSources"),
                .external(name: "RxSwift"),
                .external(name: "RxCocoa"),
                .external(name: "RxRelay"),
                .external(name: "SQLite"),
                .external(name: "Alamofire"),
            ],
            settings: .settings(configurations: [
                .debug(
                    name: Settings.debug.rawValue,
                    xcconfig: .relativeToRoot(config)
                ),
                .release(
                    name: Settings.release.rawValue,
                    xcconfig: .relativeToRoot(config)
                ),
            ])
        ),
        .target(
            name: testName,
            destinations: .iOS,
            product: .unitTests,
            bundleId: bundleTestID,
            deploymentTargets: .iOS(version),
            infoPlist: nil,
            sources: tests,
            resources: [],
            dependencies: [.target(name: appName)]
        ),
    ]
)
