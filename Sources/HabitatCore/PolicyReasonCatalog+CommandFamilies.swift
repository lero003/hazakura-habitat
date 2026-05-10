extension PolicyReasonCatalog {
    static let dynamicCommandFamilies: [CommandFamilyManifestEntry] = [
        .dynamic("swiftPackageDependencyResolutionCommands", swiftPackageDependencyResolutionCommands),
        .dynamic("secretBearingBroadSearchCommands", secretBearingBroadSearchCommands),
    ]

    static let catalogCommandFamilies = dynamicCommandFamilies
        + baselineAskFirstCommandFamilies
        + baselineForbiddenCommandFamilies
}
