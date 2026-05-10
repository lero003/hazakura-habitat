extension PolicyReasonCatalog {
    static let catalogCommandFamilies = [
        .init("swiftPackageDependencyResolutionCommands", swiftPackageDependencyResolutionCommands),
        .init("secretBearingBroadSearchCommands", secretBearingBroadSearchCommands),
    ] + baselineAskFirstCommandFamilies
        + baselineForbiddenCommandFamilies
}
