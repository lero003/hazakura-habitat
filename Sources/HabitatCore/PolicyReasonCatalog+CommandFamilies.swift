extension PolicyReasonCatalog {
    static let dynamicAskFirstCommandFamilies: [CommandFamilyManifestEntry] = [
        .dynamicAskFirst("swiftPackageDependencyResolutionCommands", swiftPackageDependencyResolutionCommands),
        .dynamicAskFirst("secretBearingBroadSearchCommands", secretBearingBroadSearchCommands),
    ]

    static let catalogCommandFamilies = dynamicAskFirstCommandFamilies
        + baselineAskFirstCommandFamilies
        + baselineForbiddenCommandFamilies
}
