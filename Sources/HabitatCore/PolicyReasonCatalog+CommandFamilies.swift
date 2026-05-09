extension PolicyReasonCatalog {
    static let catalogCommandFamilies = [
        .init("homebrewPackageManagerReviewCommands", homebrewPackageManagerReviewCommands),
        .init("ephemeralPackageExecutionCommands", ephemeralPackageExecutionCommands),
        .init("swiftPackageDependencyResolutionCommands", swiftPackageDependencyResolutionCommands),
        .init("secretBearingBroadSearchCommands", secretBearingBroadSearchCommands),
    ] + baselineAskFirstCommandFamilies
        + baselineForbiddenCommandFamilies
}
