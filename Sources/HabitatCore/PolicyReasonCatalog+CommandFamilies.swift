extension PolicyReasonCatalog {
    static let dynamicCommandFamilies: [CommandFamilyManifestEntry] = [
        .init("swiftPackageDependencyResolutionCommands", swiftPackageDependencyResolutionCommands),
        .init("secretBearingBroadSearchCommands", secretBearingBroadSearchCommands),
    ]

    static let catalogCommandFamilies = dynamicCommandFamilies
        + baselineAskFirstCommandFamilies
        + baselineForbiddenCommandFamilies
}
