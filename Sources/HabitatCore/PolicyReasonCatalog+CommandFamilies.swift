extension PolicyReasonCatalog {
    static let catalogCommandFamilies = [
        .init("baselineAskFirstCommands", baselineAskFirstCommands),
        .init("baselineForbiddenCommands", baselineForbiddenCommands),
        .init("homebrewPackageManagerReviewCommands", homebrewPackageManagerReviewCommands),
        .init("ephemeralPackageExecutionCommands", ephemeralPackageExecutionCommands),
        .init("swiftPackageDependencyResolutionCommands", swiftPackageDependencyResolutionCommands),
        .init("secretBearingBroadSearchCommands", secretBearingBroadSearchCommands),
    ] + baselineAskFirstCommandFamilies
        + baselineForbiddenCommandFamilies
}
