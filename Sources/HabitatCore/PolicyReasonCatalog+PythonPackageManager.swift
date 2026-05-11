extension PolicyReasonCatalog {
    private static let pipDependencyMutationCommandFamily = CommandFamily([
        "pip install",
        "pip3 install",
        "python -m pip install",
        "python3 -m pip install",
        "pip uninstall",
        "pip3 uninstall",
        "python -m pip uninstall",
        "python3 -m pip uninstall",
    ])
    static let pipDependencyMutationCommands = pipDependencyMutationCommandFamily.commands

    private static let pipPackageFetchAndCacheCommandFamily = CommandFamily([
        "pip download",
        "pip3 download",
        "python -m pip download",
        "python3 -m pip download",
        "pip wheel",
        "pip3 wheel",
        "python -m pip wheel",
        "python3 -m pip wheel",
        "pip index",
        "pip3 index",
        "python -m pip index",
        "python3 -m pip index",
        "pip search",
        "pip3 search",
        "python -m pip search",
        "python3 -m pip search",
        "pip cache purge",
        "pip3 cache purge",
        "python -m pip cache purge",
        "python3 -m pip cache purge",
    ])
    static let pipPackageFetchAndCacheCommands = pipPackageFetchAndCacheCommandFamily.commands

    private static let pipCacheMutationCommandFamily = CommandFamily([
        "pip cache remove",
        "pip3 cache remove",
        "python -m pip cache remove",
        "python3 -m pip cache remove",
    ])
    static let pipCacheMutationCommands = pipCacheMutationCommandFamily.commands

    static func isPipCacheMutationCommand(_ command: String) -> Bool {
        pipCacheMutationCommandFamily.contains(command)
    }

    private static let uvDependencyMutationCommandFamily = CommandFamily([
        "uv sync",
        "uv add",
        "uv remove",
        "uv pip install",
        "uv pip uninstall",
        "uv pip sync",
        "uv pip compile",
    ])
    static let uvDependencyMutationCommands = uvDependencyMutationCommandFamily.commands

    static func isPythonPackageManagerDependencyMutationCommand(_ command: String) -> Bool {
        pipDependencyMutationCommandFamily.contains(command)
            || uvDependencyMutationCommandFamily.contains(command)
    }
}
