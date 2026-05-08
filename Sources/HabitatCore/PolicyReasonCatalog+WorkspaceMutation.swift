extension PolicyReasonCatalog {
    private static let workspaceMutationCommandFamily = CommandFamily([
        "chmod",
        "chown",
        "chgrp",
        "sed -i",
        "perl -pi",
        "find -delete",
        "xargs rm",
        "cp",
        "cp -R",
        "cp -r",
        "mv",
        "rsync",
        "rsync --delete",
        "ditto",
        "tar -xf",
        "tar -xzf",
        "tar -xJf",
        "unzip",
        "truncate",
        "rm",
        "rm -r",
        "rm -rf",
    ])
    static let workspaceMutationCommands = workspaceMutationCommandFamily.commands

    static func isWorkspaceMutationCommand(_ command: String) -> Bool {
        workspaceMutationCommandFamily.contains(command)
    }
}
