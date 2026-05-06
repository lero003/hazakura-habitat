extension PolicyReasonCatalog {
    private static let homebrewDirectAskFirstCommandFamily = CommandFamily([
        "brew install",
        "brew update",
        "brew cleanup",
        "brew autoremove",
        "brew tap",
        "brew tap-new",
    ])
    static let homebrewDirectAskFirstCommands = homebrewDirectAskFirstCommandFamily.commands

    private static let homebrewBundleReviewCommandFamily = CommandFamily([
        "brew bundle",
        "brew bundle install",
        "brew bundle cleanup",
        "brew bundle dump",
    ])
    static let homebrewBundleReviewCommands = homebrewBundleReviewCommandFamily.commands

    static let homebrewAskFirstCommands = homebrewDirectAskFirstCommands
        + homebrewBundleReviewCommands

    static let homebrewPackageManagerReviewCommands = homebrewBundleReviewCommands + [
        "brew update",
        "brew cleanup",
        "brew autoremove",
        "brew tap",
        "brew tap-new",
    ]
}
