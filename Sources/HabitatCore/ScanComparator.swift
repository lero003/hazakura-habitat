import Foundation

public struct ScanComparator {
    public init() {}

    public func compare(previous: ScanResult, current: ScanResult) -> [ScanChange] {
        var changes: [ScanChange] = []

        if let generatorVersionChange = generatorVersionChange(previous: previous, current: current) {
            changes.append(generatorVersionChange)
        }

        if previous.project.packageManager != current.project.packageManager {
            changes.append(packageManagerChange(previous: previous, current: current))
        }

        if let lockfileChange = lockfileChange(previous: previous, current: current) {
            changes.append(lockfileChange)
        }

        if let packageManagerVersionChange = packageManagerVersionChange(previous: previous, current: current) {
            changes.append(packageManagerVersionChange)
        }

        if let runtimeHintChange = runtimeHintChange(previous: previous, current: current) {
            changes.append(runtimeHintChange)
        }

        if let secretFileChange = secretFileChange(previous: previous, current: current) {
            changes.append(secretFileChange)
        }

        if let symlinkedProjectSignalChange = symlinkedProjectSignalChange(previous: previous, current: current) {
            changes.append(symlinkedProjectSignalChange)
        }

        changes.append(contentsOf: missingToolChanges(previous: previous, current: current))
        changes.append(contentsOf: toolVerificationChanges(previous: previous, current: current))
        changes.append(contentsOf: preferredCommandChanges(previous: previous, current: current))
        changes.append(contentsOf: policyChanges(previous: previous, current: current))

        return changes
    }

    private func generatorVersionChange(previous: ScanResult, current: ScanResult) -> ScanChange? {
        guard previous.generatorVersion != current.generatorVersion else { return nil }

        return ScanChange(
            category: "generator",
            summary: "Generator version changed from \(previous.generatorVersion) to \(current.generatorVersion).",
            impact: "Treat report-shape or policy differences as generator changes before assuming the local environment changed."
        )
    }

    private func packageManagerChange(previous: ScanResult, current: ScanResult) -> ScanChange {
        let oldValue = previous.project.packageManager ?? "none"
        let newValue = current.project.packageManager ?? "none"
        return ScanChange(
            category: "package_manager",
            summary: "Package manager changed from \(oldValue) to \(newValue).",
            impact: "Use the current project package manager before running build, test, or install commands."
        )
    }

    private func lockfileChange(previous: ScanResult, current: ScanResult) -> ScanChange? {
        let previousLockfiles = Set(lockfiles(in: previous.project))
        let currentLockfiles = Set(lockfiles(in: current.project))
        let added = currentLockfiles.subtracting(previousLockfiles).sorted()
        let removed = previousLockfiles.subtracting(currentLockfiles).sorted()
        guard !added.isEmpty || !removed.isEmpty else { return nil }

        let parts = [
            added.isEmpty ? nil : "added \(added.joined(separator: ", "))",
            removed.isEmpty ? nil : "removed \(removed.joined(separator: ", "))",
        ].compactMap { $0 }

        return ScanChange(
            category: "lockfiles",
            summary: "Lockfiles changed: \(parts.joined(separator: "; ")).",
            impact: "Re-check package manager selection and ask before dependency installs."
        )
    }

    private func packageManagerVersionChange(previous: ScanResult, current: ScanResult) -> ScanChange? {
        guard previous.project.packageManager == current.project.packageManager,
              let packageManager = current.project.packageManager,
              ["npm", "pnpm", "yarn", "bun"].contains(packageManager)
        else {
            return nil
        }

        let previousVersion = packageManagerVersionLabel(for: previous.project)
        let currentVersion = packageManagerVersionLabel(for: current.project)
        guard previousVersion != currentVersion else { return nil }

        return ScanChange(
            category: "package_manager_version",
            summary: "Package manager version guidance changed from \(previousVersion) to \(currentVersion).",
            impact: "Re-check the active \(packageManager) version before dependency installs; follow current agent_context.md guidance."
        )
    }

    private func runtimeHintChange(previous: ScanResult, current: ScanResult) -> ScanChange? {
        let changedHints = runtimeHintLabels(previous: previous.project.runtimeHints, current: current.project.runtimeHints)
        guard !changedHints.isEmpty else { return nil }

        return ScanChange(
            category: "runtime_hints",
            summary: "Runtime version guidance changed: \(changedHints.joined(separator: "; ")).",
            impact: "Re-check active runtimes before dependency installs or build/test commands; follow current command policy."
        )
    }

    private func secretFileChange(previous: ScanResult, current: ScanResult) -> ScanChange? {
        let previousSecretFiles = Set(secretFiles(in: previous.project))
        let currentSecretFiles = Set(secretFiles(in: current.project))
        let added = currentSecretFiles.subtracting(previousSecretFiles).sorted()
        let removed = previousSecretFiles.subtracting(currentSecretFiles).sorted()
        guard !added.isEmpty || !removed.isEmpty else { return nil }

        let parts = [
            added.isEmpty ? nil : "added \(summarize(added))",
            removed.isEmpty ? nil : "removed \(summarize(removed))",
        ].compactMap { $0 }

        return ScanChange(
            category: "secret_files",
            summary: "Secret-bearing file signals changed: \(parts.joined(separator: "; ")).",
            impact: "Do not read, compare, open, edit, copy, move, sync, upload, archive, or load secret/auth/private-key files; follow current Avoid and Forbidden guidance."
        )
    }

    private func symlinkedProjectSignalChange(previous: ScanResult, current: ScanResult) -> ScanChange? {
        let previousSymlinks = Set(previous.project.symlinkedFiles)
        let currentSymlinks = Set(current.project.symlinkedFiles)
        let added = currentSymlinks.subtracting(previousSymlinks).sorted()
        let removed = previousSymlinks.subtracting(currentSymlinks).sorted()
        guard !added.isEmpty || !removed.isEmpty else { return nil }

        let parts = [
            added.isEmpty ? nil : "added \(summarize(added))",
            removed.isEmpty ? nil : "removed \(summarize(removed))",
        ].compactMap { $0 }

        return ScanChange(
            category: "project_symlinks",
            summary: "Project symlink signals changed: \(parts.joined(separator: "; ")).",
            impact: "Review symlink targets before following linked metadata or using dependency signals."
        )
    }

    private func missingToolChanges(previous: ScanResult, current: ScanResult) -> [ScanChange] {
        let previousRelevantTools = relevantToolNames(for: previous)
        let currentRelevantTools = relevantToolNames(for: current)
        let previousMissing = missingTools(in: previous, limitedTo: previousRelevantTools)
        let currentMissing = missingTools(in: current, limitedTo: currentRelevantTools)
        let currentFailedChecks = failedToolChecks(in: current, limitedTo: currentRelevantTools)
        let newlyMissing = currentMissing.subtracting(previousMissing).sorted()
        let noLongerMissing = previousMissing.subtracting(currentMissing)
        let resolved = noLongerMissing
            .filter { currentRelevantTools.contains($0) && toolIsAvailable($0, in: current) && !currentFailedChecks.contains($0) }
            .sorted()
        let noLongerRelevant = noLongerMissing
            .filter { !currentRelevantTools.contains($0) }
            .sorted()
        var changes: [ScanChange] = []

        if !newlyMissing.isEmpty {
            changes.append(ScanChange(
                category: "missing_tools",
                summary: "Project-relevant tools are now missing: \(newlyMissing.joined(separator: ", ")).",
                impact: "Ask before running those commands or substituting another tool."
            ))
        }

        if !resolved.isEmpty {
            changes.append(ScanChange(
                category: "missing_tools",
                summary: "Project-relevant tools are now available: \(resolved.joined(separator: ", ")).",
                impact: "Preferred project commands may be runnable without missing-tool fallback."
            ))
        }

        if !noLongerRelevant.isEmpty {
            changes.append(ScanChange(
                category: "missing_tools",
                summary: "Previously missing tools are no longer project-relevant: \(noLongerRelevant.joined(separator: ", ")).",
                impact: "Do not treat them as available; follow the current project signals and command policy."
            ))
        }

        return changes
    }

    private func toolVerificationChanges(previous: ScanResult, current: ScanResult) -> [ScanChange] {
        let previousRelevantTools = relevantToolNames(for: previous)
        let currentRelevantTools = relevantToolNames(for: current)
        let previousFailed = failedToolChecks(in: previous, limitedTo: previousRelevantTools)
        let currentFailed = failedToolChecks(in: current, limitedTo: currentRelevantTools)
        let newlyFailed = currentFailed.subtracting(previousFailed).sorted()
        let nowPassing = previousFailed
            .subtracting(currentFailed)
            .filter { currentRelevantTools.contains($0) }
            .sorted()
        var changes: [ScanChange] = []

        if !newlyFailed.isEmpty {
            changes.append(ScanChange(
                category: "tool_verification",
                summary: "Project-relevant tool checks now fail: \(newlyFailed.joined(separator: ", ")).",
                impact: "Treat related build, test, or install commands as Ask First until the current command policy allows them."
            ))
        }

        if !nowPassing.isEmpty {
            changes.append(ScanChange(
                category: "tool_verification",
                summary: "Project-relevant tool checks now pass: \(nowPassing.joined(separator: ", ")).",
                impact: "Preferred commands may be runnable if the current command policy has no related guard."
            ))
        }

        return changes
    }

    private func toolIsAvailable(_ toolName: String, in result: ScanResult) -> Bool {
        result.tools.resolvedPaths.contains { tool in
            tool.name == toolName && !tool.paths.isEmpty
        }
    }

    private func preferredCommandChanges(previous: ScanResult, current: ScanResult) -> [ScanChange] {
        guard previous.project.packageManager == current.project.packageManager else {
            return []
        }

        guard previous.policy.preferredCommands != current.policy.preferredCommands else {
            return []
        }

        return [
            ScanChange(
                category: "preferred_commands",
                summary: "Preferred commands changed from \(summarizeCommands(previous.policy.preferredCommands)) to \(summarizeCommands(current.policy.preferredCommands)).",
                impact: "Re-check command_policy.md; use only current allowed preferred commands."
            )
        ]
    }

    private func policyChanges(previous: ScanResult, current: ScanResult) -> [ScanChange] {
        let previousAskFirst = Set(previous.policy.askFirstCommands)
        let currentAskFirst = Set(current.policy.askFirstCommands)
        let previousForbidden = Set(previous.policy.forbiddenCommands)
        let currentForbidden = Set(current.policy.forbiddenCommands)
        var changes: [ScanChange] = []

        let escalatedToForbidden = currentForbidden.intersection(previousAskFirst).sorted()
        if !escalatedToForbidden.isEmpty {
            changes.append(ScanChange(
                category: "command_policy",
                summary: "Commands changed from Ask First to Forbidden: \(summarize(escalatedToForbidden)).",
                impact: "Refuse these commands under the current scan policy."
            ))
        }

        let downgradedToAskFirst = currentAskFirst.intersection(previousForbidden).sorted()
        if !downgradedToAskFirst.isEmpty {
            changes.append(ScanChange(
                category: "command_policy",
                summary: "Commands changed from Forbidden to Ask First: \(summarize(downgradedToAskFirst)).",
                impact: "Ask before these commands; do not refuse solely because a previous scan did."
            ))
        }

        let addedAskFirst = currentAskFirst
            .subtracting(previousAskFirst)
            .subtracting(previousForbidden)
            .sorted()
        if !addedAskFirst.isEmpty {
            changes.append(ScanChange(
                category: "command_policy",
                summary: "New Ask First commands: \(summarize(addedAskFirst)).",
                impact: "Ask before these commands even if a previous scan did not require it."
            ))
        }

        let addedForbidden = currentForbidden
            .subtracting(previousForbidden)
            .subtracting(previousAskFirst)
            .sorted()
        if !addedForbidden.isEmpty {
            changes.append(ScanChange(
                category: "command_policy",
                summary: "New Forbidden commands: \(summarize(addedForbidden)).",
                impact: "Refuse these commands under the current scan policy."
            ))
        }

        let resolvedAskFirst = previousAskFirst
            .subtracting(currentAskFirst)
            .subtracting(currentForbidden)
            .sorted()
        if !resolvedAskFirst.isEmpty {
            changes.append(ScanChange(
                category: "command_policy",
                summary: "Ask First commands no longer highlighted: \(summarize(resolvedAskFirst)).",
                impact: "Do not ask solely because a previous scan did; apply the current command policy."
            ))
        }

        let removedForbidden = previousForbidden
            .subtracting(currentForbidden)
            .subtracting(currentAskFirst)
            .sorted()
        if !removedForbidden.isEmpty {
            changes.append(ScanChange(
                category: "command_policy",
                summary: "Forbidden commands no longer highlighted: \(summarize(removedForbidden)).",
                impact: "Do not refuse solely because a previous scan did; apply the current command policy."
            ))
        }

        return changes
    }

    private func lockfiles(in project: ProjectInfo) -> [String] {
        [
            "package-lock.json",
            "npm-shrinkwrap.json",
            "pnpm-lock.yaml",
            "yarn.lock",
            "bun.lock",
            "bun.lockb",
            "uv.lock",
            "Pipfile.lock",
            "Gemfile.lock",
            "Package.resolved",
            "Podfile.lock",
            "Cartfile.resolved",
        ].filter { project.detectedFiles.contains($0) }
    }

    private func secretFiles(in project: ProjectInfo) -> [String] {
        project.detectedFiles.filter { file in
            file == ".env"
                || file == ".env.example"
                || (file.hasPrefix(".env.") && file != ".env.example")
                || file == ".envrc"
                || file == ".envrc.example"
                || (file.hasPrefix(".envrc.") && file != ".envrc.example")
                || file == ".netrc"
                || file == ".npmrc"
                || file == ".pnpmrc"
                || file == ".yarnrc"
                || file == ".yarnrc.yml"
                || file == ".pypirc"
                || file == "pip.conf"
                || file == ".gem/credentials"
                || file == ".bundle/config"
                || file == ".cargo/credentials.toml"
                || file == ".cargo/credentials"
                || file == "auth.json"
                || file == ".composer/auth.json"
                || file == ".aws/credentials"
                || file == ".aws/config"
                || file == ".config/gcloud/application_default_credentials.json"
                || file == ".docker/config.json"
                || file == ".kube/config"
                || isSSHPrivateKeyFilename(file)
        }
    }

    private func isSSHPrivateKeyFilename(_ file: String) -> Bool {
        let basename = URL(fileURLWithPath: file).lastPathComponent.lowercased()
        guard !basename.hasSuffix(".pub") else { return false }

        if ["id_rsa", "id_dsa", "id_ecdsa", "id_ed25519"].contains(basename) {
            return true
        }

        return [".pem", ".key", ".p8", ".p12", ".ppk"].contains { basename.hasSuffix($0) }
    }

    private func missingTools(in result: ScanResult, limitedTo relevantTools: Set<String>) -> Set<String> {
        Set(result.tools.resolvedPaths.compactMap { tool in
            relevantTools.contains(tool.name) && tool.paths.isEmpty ? tool.name : nil
        })
    }

    private func failedToolChecks(in result: ScanResult, limitedTo relevantTools: Set<String>) -> Set<String> {
        Set(result.tools.versions.compactMap { tool in
            relevantTools.contains(tool.name)
                && !tool.available
                && toolIsAvailable(tool.name, in: result)
                ? tool.name
                : nil
        })
    }

    private func relevantToolNames(for result: ScanResult) -> Set<String> {
        var names = Set<String>()

        if let packageManager = result.project.packageManager {
            if let executableName = executableName(forPackageManager: packageManager) {
                names.insert(executableName)
            }

            if ["npm", "pnpm", "yarn", "bun"].contains(packageManager) {
                names.insert("node")
            }

            if packageManager == "uv" {
                names.insert("python3")
            }

            if ["swiftpm", "xcodebuild"].contains(packageManager) {
                names.insert("xcode-select")
            }
        }

        if result.project.runtimeHints.node != nil {
            names.insert("node")
        }

        if result.project.runtimeHints.python != nil {
            names.insert("python3")
        }

        if result.project.runtimeHints.ruby != nil {
            names.insert("ruby")
        }

        return names
    }

    private func executableName(forPackageManager packageManager: String) -> String? {
        switch packageManager {
        case "npm", "pnpm", "yarn", "bun", "uv", "go", "cargo", "carthage", "xcodebuild":
            return packageManager
        case "bundler":
            return "bundle"
        case "homebrew":
            return "brew"
        case "cocoapods":
            return "pod"
        case "swiftpm":
            return "swift"
        case "python":
            return "python3"
        default:
            return nil
        }
    }

    private func summarize(_ values: [String], limit: Int = 3) -> String {
        let prefix = values.prefix(limit).joined(separator: ", ")
        let remainingCount = values.count - limit
        guard remainingCount > 0 else { return prefix }
        return "\(prefix), and \(remainingCount) more"
    }

    private func summarizeCommands(_ values: [String]) -> String {
        values.isEmpty ? "none" : summarize(values)
    }

    private func packageManagerVersionLabel(for project: ProjectInfo) -> String {
        guard let packageManager = project.packageManager,
              let version = project.packageManagerVersion
        else {
            return "none"
        }

        if let source = project.packageManagerVersionSource {
            return "\(packageManager)@\(version) via \(source)"
        }

        return "\(packageManager)@\(version)"
    }

    private func runtimeHintLabels(previous: RuntimeHints, current: RuntimeHints) -> [String] {
        [
            runtimeHintLabel(name: "Node", previous: previous.node, current: current.node),
            runtimeHintLabel(name: "Python", previous: previous.python, current: current.python),
            runtimeHintLabel(name: "Ruby", previous: previous.ruby, current: current.ruby),
        ].compactMap { $0 }
    }

    private func runtimeHintLabel(name: String, previous: String?, current: String?) -> String? {
        guard previous != current else { return nil }
        return "\(name) \(previous ?? "none") -> \(current ?? "none")"
    }
}
