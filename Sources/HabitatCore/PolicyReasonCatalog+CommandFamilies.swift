extension PolicyReasonCatalog {
    static let dynamicCommandFamilies: [CommandFamilyManifestEntry] = [
        .init("swiftPackageDependencyResolutionCommands", swiftPackageDependencyResolutionCommands, source: .dynamic),
        .init("secretBearingBroadSearchCommands", secretBearingBroadSearchCommands, source: .dynamic),
    ]

    static let catalogCommandFamilies = dynamicCommandFamilies
        + baselineAskFirstCommandFamilies
        + baselineForbiddenCommandFamilies
}
