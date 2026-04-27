import Foundation

public struct ScanComparator {
    public init() {}

    public func compare(previous: ScanResult, current: ScanResult) -> [ScanChange] {
        var changes: [ScanChange] = []

        if previous.project.packageManager != current.project.packageManager {
            changes.append(packageManagerChange(previous: previous, current: current))
        }

        if let lockfileChange = lockfileChange(previous: previous, current: current) {
            changes.append(lockfileChange)
        }

        changes.append(contentsOf: missingToolChanges(previous: previous, current: current))
        changes.append(contentsOf: toolVerificationChanges(previous: previous, current: current))
        changes.append(contentsOf: policyChanges(previous: previous, current: current))

        return changes
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

    private func missingToolChanges(previous: ScanResult, current: ScanResult) -> [ScanChange] {
        let previousRelevantTools = relevantToolNames(for: previous)
        let currentRelevantTools = relevantToolNames(for: current)
        let previousMissing = missingTools(in: previous, limitedTo: previousRelevantTools)
        let currentMissing = missingTools(in: current, limitedTo: currentRelevantTools)
        let newlyMissing = currentMissing.subtracting(previousMissing).sorted()
        let noLongerMissing = previousMissing.subtracting(currentMissing)
        let resolved = noLongerMissing
            .filter { currentRelevantTools.contains($0) && toolIsAvailable($0, in: current) }
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
}
