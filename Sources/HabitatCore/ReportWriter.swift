import Foundation

public struct ReportWriter {
    private let agentContextLineLimit = 120

    public init() {}

    public func write(scanResult: ScanResult, outputURL: URL) throws {
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        let result = scanResult.withPolicy(
            scanResult.policy.withReviewFirstCommandReasons(
                commandPolicyReviewFirstCommandReasons(scanResult)
            )
        )
        let agentContextText = agentContext(result)
        let commandPolicyText = commandPolicy(result)
        let environmentReportText = environmentReport(result)
        let artifacts = [
            markdownArtifact(name: "agent_context.md", role: "agent_context", readOrder: 1, text: agentContextText),
            markdownArtifact(name: "command_policy.md", role: "command_policy", readOrder: 2, text: commandPolicyText),
            markdownArtifact(name: "environment_report.md", role: "environment_report", readOrder: 3, text: environmentReportText)
        ]

        try writeJSON(scanResult: result.withArtifacts(artifacts), outputURL: outputURL)
        try writeText(agentContextText, to: outputURL.appendingPathComponent("agent_context.md"))
        try writeText(commandPolicyText, to: outputURL.appendingPathComponent("command_policy.md"))
        try writeText(environmentReportText, to: outputURL.appendingPathComponent("environment_report.md"))
    }

    private func writeJSON(scanResult: ScanResult, outputURL: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(scanResult)
        try data.write(to: outputURL.appendingPathComponent("scan_result.json"))
    }

    private func writeText(_ text: String, to url: URL) throws {
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    private func markdownArtifact(name: String, role: String, readOrder: Int, text: String) -> GeneratedArtifact {
        let artifactLineCount = lineCount(text)
        let lineLimit = role == "agent_context" ? agentContextLineLimit : nil
        return GeneratedArtifact(
            name: name,
            role: role,
            format: "markdown",
            agentUse: artifactAgentUse(role: role),
            readTrigger: artifactReadTrigger(role: role),
            lineCount: artifactLineCount,
            characterCount: text.count,
            readOrder: readOrder,
            entrySection: artifactEntrySection(role: role),
            sections: markdownSections(text),
            lineLimit: lineLimit,
            withinLineLimit: lineLimit.map { artifactLineCount <= $0 }
        )
    }

    private func artifactAgentUse(role: String) -> String {
        switch role {
        case "agent_context":
            return "read_first"
        case "command_policy":
            return "consult_before_risky_commands"
        case "environment_report":
            return "debug_audit_only"
        default:
            return "reference"
        }
    }

    private func artifactReadTrigger(role: String) -> String {
        switch role {
        case "agent_context":
            return "before_any_project_command"
        case "command_policy":
            return "before_risky_mutating_secret_or_environment_sensitive_commands"
        case "environment_report":
            return "only_for_diagnostics_or_audit"
        default:
            return "as_needed"
        }
    }

    private func artifactEntrySection(role: String) -> String {
        switch role {
        case "agent_context":
            return "Use"
        case "command_policy":
            return "Review First"
        case "environment_report":
            return "Diagnostics"
        default:
            return "Overview"
        }
    }

    private func lineCount(_ text: String) -> Int {
        guard !text.isEmpty else { return 0 }
        return text.split(separator: "\n", omittingEmptySubsequences: false).count
    }

    private func markdownSections(_ text: String) -> [String] {
        text.split(separator: "\n")
            .compactMap { line -> String? in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard trimmed.hasPrefix("#") else { return nil }
                return trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "# "))
            }
    }

    private func agentContext(_ result: ScanResult) -> String {
        let preferredCommands = markdownPreferredCommands(result)
        let useLines: [String]
        let preferLines: [String]

        if hasProjectPathVerificationGuard(result) {
            useLines = ["Verify the project path before running project commands."]
            preferLines = ["Prefer path existence checks before project commands."]
        } else {
            let packageManagerUse = result.project.packageManager.map { packageManager in
                if let verificationLine = selectedToolVerificationUseLine(result, packageManager: packageManager) {
                    return verificationLine
                }

                if let version = result.project.packageManagerVersion {
                    if result.project.declaredPackageManager == packageManager {
                        return "Use `\(packageManager)@\(version)` because `package.json` packageManager points to it."
                    }

                    if let source = result.project.packageManagerVersionSource {
                        return "Use `\(packageManager)@\(version)` because `\(source)` pins it."
                    }

                    return "Use `\(packageManager)@\(version)` because project metadata pins it."
                }

                return "Use \(packageManagerUsePhrase(packageManager, result: result)) because project files point to it."
            }

            useLines = [packageManagerUse].compactMap { $0 }
            preferLines = preferredCommands.prefix(2).map { "Prefer `\($0)`." }
        }
        let avoidLimit = hasDetectedSecretValueFile(result.project) ? 10 : 9
        let avoidLines = prioritizedForbiddenCommands(result)
            .prefix(avoidLimit)
            .map { avoidLine(for: $0, result: result) }
        let askFirstCommands = prioritizedAskFirstCommands(result)
        let askLines = agentContextAskFirstLines(askFirstCommands, result: result)
        let relevantDiagnostics = agentRelevantDiagnostics(result)
        let mismatchLines = result.warnings.isEmpty
            ? ["- Mismatches: none detected."]
            : limitedBulletLines(result.warnings.map { "Mismatch: \($0)" }, limit: 10, overflowLabel: "warnings")
        let changeLines = limitedBulletLines(
            result.changes.map { "\($0.summary) \($0.impact)" },
            limit: 6,
            overflowLabel: "scan changes"
        )
        let diagnosticLines = limitedBulletLines(
            relevantDiagnostics,
            limit: 4,
            overflowLabel: "relevant command diagnostics"
        )
        let noteLines = (changeLines + diagnosticLines).isEmpty
            ? ["- Scan completed without relevant command diagnostics."]
            : changeLines + diagnosticLines

        return """
        # Agent Context

        ## Use
        \(bulletList(useLines, fallback: "- Use read-only inspection first."))

        ## Prefer
        \(bulletList(preferLines, fallback: "- Prefer read-only inspection before mutation."))

        ## Ask First
        \(askLines.joined(separator: "\n"))

        ## Do Not
        \(bulletList(avoidLines, fallback: "- Do not mutate global environment state."))

        ## Notes
        - Scanned at: \(result.scannedAt)
        - Project: \(result.projectPath)
        - Read order: this file first; `command_policy.md` before risky commands; `environment_report.md` only for diagnostics.
        - Scope: short working context; full approval detail is in `command_policy.md`.
        \(mismatchLines.joined(separator: "\n"))
        \(noteLines.joined(separator: "\n"))
        """
    }

    private func commandPolicy(_ result: ScanResult) -> String {
        let preferredCommands = markdownPreferredCommands(result)
        let secretBearingFiles = secretValueFiles(result.project)
        let secretGuidance = secretBearingFileGuidance(files: secretBearingFiles)
        let askFirstCommands = prioritizedAskFirstCommands(result)
        let reviewFirst = commandPolicyReviewFirst(result)
        let reasonLegend = commandPolicyReasonLegend(result)
        var allowed: [String]

        if hasProjectPathVerificationGuard(result) {
            allowed = ["path existence checks"]
        } else {
            allowed = preferredCommands + [
                allowedReadOnlyInspectionLine(secretBearingFiles: secretBearingFiles)
            ]
        }

        var sections = [
            """
            # Command Policy

            This policy is advisory. Habitat does not block commands. `Forbidden` means this generated context tells the agent not to run the command.
            """
        ]

        sections.append(
            """
            ## Policy Index
            \(bulletList(commandPolicyIndex(
                reviewFirstCount: reviewFirst.count,
                reasonCodeCount: reasonLegend.count,
                secretBearingFileCount: secretBearingFiles.count,
                allowedCount: allowed.count,
                askFirstCount: askFirstCommands.count,
                forbiddenCount: result.policy.forbiddenCommands.count
            ), fallback: "- Review `agent_context.md` first."))
            """
        )

        if !reviewFirst.isEmpty {
            sections.append(
                """
                ## Review First
                \(bulletList(reviewFirst, fallback: "- Review `agent_context.md` before project commands."))
                """
            )
        }

        if !reasonLegend.isEmpty {
            sections.append(
                """
                ## Reason Codes
                \(bulletList(reasonLegend, fallback: "- `user_approval_required` - Requires user approval before execution."))
                """
            )
        }

        if !secretGuidance.isEmpty {
            sections.append(secretGuidance)
        }

        sections.append(contentsOf: [
            """
            ## Allowed
            \(bulletList(allowed.map { "`\($0)`" }, fallback: "- `read-only inspection`"))
            """,
            """
            ## Ask First
            \(bulletList(askFirstCommands.map(askFirstPolicyLine), fallback: "- `dependency installation`"))
            """,
            """
            ## Forbidden
            \(bulletList(result.policy.forbiddenCommands.map(forbiddenPolicyLine), fallback: "- `sudo`"))
            """
        ])

        sections.append(
            """
            ## If Dependency Installation Seems Necessary
            - Re-check lockfiles and version hints first.
            - Prefer the project-specific package manager from `agent_context.md`.
            - Ask before any install, upgrade, uninstall, or global mutation.
            """
        )

        return sections.joined(separator: "\n\n")
    }

    private func commandPolicyIndex(
        reviewFirstCount: Int,
        reasonCodeCount: Int,
        secretBearingFileCount: Int,
        allowedCount: Int,
        askFirstCount: Int,
        forbiddenCount: Int
    ) -> [String] {
        var lines = [
            "`Review First` - \(counted(reviewFirstCount, singular: "highest-priority approval rule", plural: "highest-priority approval rules")) with reasons.",
            "`Reason Codes` - \(counted(reasonCodeCount, singular: "reason family", plural: "reason families")) used by this policy.",
        ]

        if secretBearingFileCount > 0 {
            lines.append(
                "`If Secret-Bearing Files Are Detected` - \(counted(secretBearingFileCount, singular: "detected path", plural: "detected paths")) requiring exclusions before broad search or export."
            )
        }

        lines.append(contentsOf: [
            "`Allowed` - \(counted(allowedCount, singular: "concrete safe starting point", plural: "concrete safe starting points")).",
            "`Ask First` - \(counted(askFirstCount, singular: "command or command family", plural: "commands or command families")) requiring approval.",
            "`Forbidden` - \(counted(forbiddenCount, singular: "command or command family", plural: "commands or command families")) to avoid."
        ])

        return lines
    }

    private func allowedReadOnlyInspectionLine(secretBearingFiles: [String]) -> String {
        if secretBearingFiles.isEmpty {
            return "read-only project inspection, including rg <pattern>"
        }

        return "targeted read-only project inspection that avoids detected secret-bearing paths"
    }

    private func counted(_ count: Int, singular: String, plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }

    private func commandPolicyReviewFirst(_ result: ScanResult) -> [String] {
        let reasons = result.policy.reviewFirstCommandReasons.isEmpty
            ? commandPolicyReviewFirstCommandReasons(result)
            : result.policy.reviewFirstCommandReasons

        return reasons.map {
            "`\($0.command)` (`\($0.reasonCode)`) - \($0.reason)"
        }
    }

    private func commandPolicyReviewFirstCommandReasons(_ result: ScanResult) -> [PolicyCommandReason] {
        prioritizedAskFirstCommands(result)
            .prefix(6)
            .map { command in
                let reason = PolicyReasonCatalog.askFirstReason(for: command)
                return PolicyCommandReason(
                    command: command,
                    classification: "ask_first",
                    reasonCode: reason.code,
                    reason: reason.text
                )
            }
    }

    private func askFirstPolicyLine(for command: String) -> String {
        let reason = PolicyReasonCatalog.askFirstReason(for: command)
        return "`\(command)` (`\(reason.code)`)"
    }

    private func forbiddenPolicyLine(for command: String) -> String {
        let reason = PolicyReasonCatalog.forbiddenReason(for: command)
        return "`\(command)` (`\(reason.code)`)"
    }

    private func commandPolicyReasonLegend(_ result: ScanResult) -> [String] {
        let reasons = PolicyReasonCatalog.legend(
            askFirstCommands: prioritizedAskFirstCommands(result),
            forbiddenCommands: result.policy.forbiddenCommands
        )
        return reasons.map { "`\($0.code)` - \($0.text)" }
    }

    private func environmentReport(_ result: ScanResult) -> String {
        let tools = result.tools.resolvedPaths.map { tool in
            let joined = tool.paths.isEmpty ? "missing" : tool.paths.joined(separator: ", ")
            return "- \(tool.name): \(joined)"
        }.joined(separator: "\n")

        let versions = result.tools.versions.map { tool in
            "- \(tool.name): \(tool.version ?? "unavailable")"
        }.joined(separator: "\n")

        let changes = result.changes.map { change in
            "[\(change.category)] \(change.summary) \(change.impact)"
        }

        let files = result.project.detectedFiles.isEmpty
            ? "- None"
            : result.project.detectedFiles.map { "- \($0)" }.joined(separator: "\n")
        let symlinkedFiles = result.project.symlinkedFiles.isEmpty
            ? "- None"
            : result.project.symlinkedFiles.map { "- \($0)" }.joined(separator: "\n")

        return """
        # Environment Report

        ## System
        - OS: \(result.system.operatingSystemVersion)
        - Architecture: \(result.system.architecture)
        - Shell: \(result.system.shell ?? "unknown")

        ## Project Signals
        \(files)

        ## Symlinked Project Signals
        \(symlinkedFiles)

        ## Resolved Tools
        \(tools)

        ## Tool Versions
        \(versions)

        ## Changes Since Previous Scan
        \(bulletList(changes, fallback: "- None"))

        ## Warnings
        \(bulletList(result.warnings, fallback: "- None"))

        ## Diagnostics
        \(bulletList(result.diagnostics, fallback: "- None"))

        ## Privacy Note
        - This scan avoids reading `.env` values, secrets, browser data, and mail data.
        """
    }

    private func bulletList(_ items: [String], fallback: String) -> String {
        guard !items.isEmpty else { return fallback }
        return items.map { "- \($0)" }.joined(separator: "\n")
    }

    private func limitedBulletLines(
        _ items: [String],
        limit: Int,
        overflowLabel: String,
        overflowDestination: String = "environment_report.md"
    ) -> [String] {
        guard items.count > limit else {
            return items.map { "- \($0)" }
        }

        let shown = items.prefix(limit).map { "- \($0)" }
        let hiddenCount = items.count - limit
        return shown + ["- \(hiddenCount) additional \(overflowLabel) in `\(overflowDestination)`."]
    }

    private func agentContextAskFirstLines(_ commands: [String], result: ScanResult) -> [String] {
        guard !commands.isEmpty else {
            return ["- Ask before dependency installation or version changes."]
        }

        let limit = 4
        let shownCommands = Array(commands.prefix(limit))
        var lines = shownCommands.map { agentContextAskFirstLine(for: $0, result: result) }

        let hiddenGitGuardsSummarized = shouldSummarizeHiddenGitMutationGuards(commands: commands, shownCommands: shownCommands)
        if hiddenGitGuardsSummarized {
            lines.append("- Ask before Git/GitHub workspace, history, branch, or remote mutations; see `command_policy.md`.")
        }

        if commands.count > limit {
            let hiddenCommands = Array(commands.dropFirst(limit))
            let hiddenCount = commands.count - limit
            let reasonSuffix = hiddenAskFirstReasonSuffix(
                for: hiddenCommands,
                gitGuardsSummarized: hiddenGitGuardsSummarized
            )
            lines.append("- \(hiddenCount) additional Ask First commands or command families in `command_policy.md`\(reasonSuffix).")
        }

        return lines
    }

    private func agentContextAskFirstLine(for command: String, result: ScanResult) -> String {
        if command == "recursive project search without excluding secret-bearing files" {
            return "- Ask before broad `rg`/`grep -R`/`git grep` unless detected secret-bearing files are excluded; start with `\(broadSearchShape(for: result.project))`."
        }

        return "- Ask before `\(command)`."
    }

    private func hiddenAskFirstReasonSuffix(for commands: [String], gitGuardsSummarized: Bool) -> String {
        let commandsForReasonSummary = gitGuardsSummarized
            ? commands.filter { !PolicyReasonCatalog.isGitOrGitHubMutationGuard($0) }
            : commands
        let reasonCodes = PolicyReasonCatalog.legend(
            askFirstCommands: commandsForReasonSummary,
            forbiddenCommands: []
        ).map(\.code)
        guard !reasonCodes.isEmpty else {
            return gitGuardsSummarized ? " (Git/GitHub guards summarized above)" : ""
        }
        let summarizedCodes = reasonCodes.prefix(3).map { "`\($0)`" }.joined(separator: ", ")
        let overflow = reasonCodes.count > 3 ? ", more" : ""
        let label = gitGuardsSummarized ? "other reason codes" : "reason codes"
        return " (\(label): \(summarizedCodes)\(overflow))"
    }

    private func shouldSummarizeHiddenGitMutationGuards(commands: [String], shownCommands: [String]) -> Bool {
        let hiddenCommands = Set(commands.dropFirst(shownCommands.count))
        guard hiddenCommands.contains(where: PolicyReasonCatalog.isGitOrGitHubMutationGuard) else {
            return false
        }

        return !shownCommands.contains(where: PolicyReasonCatalog.isGitOrGitHubMutationGuard)
    }

    private func avoidLine(for command: String, result: ScanResult) -> String {
        switch command {
        case "destructive file deletion outside the selected project":
            return "Do not delete files outside the selected project."
        case "remote script execution through curl or wget":
            return "Do not execute remote scripts through `curl` or `wget` piped into a shell."
        case "dump environment variables":
            return "Do not dump environment variables."
        case "read clipboard contents":
            return "Do not read clipboard contents."
        case "read shell history":
            return "Do not read shell history."
        case "read browser or mail data":
            return "Do not inspect browser profiles, cookies, history, or local mail data."
        case "load secret environment files":
            return "Do not source or load secret environment files."
        case "render Docker Compose config when secret environment files exist":
            return "Do not render Docker Compose config while secret environment files may be interpolated."
        case "recursive project search without excluding secret-bearing files":
            let rgShape = broadSearchShape(for: result.project)
            return "Do not run broad `rg`/`grep -R`/`git grep` unless detected secret-bearing files are excluded; start with `\(rgShape)`."
        case "project copy, sync, or archive without excluding secret-bearing files":
            return "Do not copy, sync, or archive the project without excluding detected secret-bearing files."
        case "read .env values":
            return "Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive `.env` files."
        case "read .envrc values":
            return "Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive `.envrc` files."
        case "read .netrc values":
            return "Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive `.netrc` files."
        case "read package manager auth config values":
            return "Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive package manager auth config files."
        case "read private keys":
            return "Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, archive, or load private keys."
        case "read local cloud and container credential files":
            return "Do not read, open, copy, upload, or archive local cloud or container credential files, or print cloud auth tokens."
        default:
            return "Do not run `\(command)`."
        }
    }

    private func broadSearchShape(for project: ProjectInfo) -> String {
        let globs = searchExclusionGlobs(for: secretValueFiles(project))
        guard !globs.isEmpty else { return "rg <pattern>" }
        return "rg <pattern> \(globs.joined(separator: " "))"
    }

    private func agentRelevantDiagnostics(_ result: ScanResult) -> [String] {
        let relevantCommands = agentRelevantCommandNames(result)
        guard !relevantCommands.isEmpty else { return [] }

        return result.diagnostics.filter { diagnostic in
            relevantCommands.contains { commandName in
                diagnostic == commandName || diagnostic.hasPrefix("\(commandName) ")
            }
        }
    }

    private func prioritizedAskFirstCommands(_ result: ScanResult) -> [String] {
        var prioritized: [String] = []

        appendAskFirstCommands(
            from: result.policy.askFirstCommands,
            to: &prioritized
        ) { command in
            command == "running project commands before project path is verified"
                || command.hasPrefix("running ")
                || command == "Swift/Xcode build commands before xcode-select -p succeeds"
                || command.hasPrefix("dependency installs ")
                || command == "following project symlinks before reviewing targets"
                || command == "recursive project search without excluding secret-bearing files"
        }

        appendAskFirstCommands(
            from: result.policy.askFirstCommands,
            to: &prioritized
        ) { command in
            selectedPackageManagerMutationCommands(result).contains(command)
        }

        appendAskFirstCommands(
            from: result.policy.askFirstCommands,
            to: &prioritized
        ) { command in
            command == "modifying lockfiles"
                || command == "modifying version manager files"
        }

        appendAskFirstCommands(
            from: result.policy.askFirstCommands,
            to: &prioritized,
            where: PolicyReasonCatalog.isGitOrGitHubMutationGuard
        )

        for command in result.policy.askFirstCommands where !prioritized.contains(command) {
            prioritized.append(command)
        }

        return prioritized
    }

    private func appendAskFirstCommands(
        from source: [String],
        to prioritized: inout [String],
        where shouldInclude: (String) -> Bool
    ) {
        for command in source where shouldInclude(command) && !prioritized.contains(command) {
            prioritized.append(command)
        }
    }

    private func selectedPackageManagerMutationCommands(_ result: ScanResult) -> [String] {
        switch result.project.packageManager {
        case "npm":
            return ["npm install", "npm ci", "npm update", "npm uninstall", "npm remove", "npm rm"]
        case "pnpm":
            return ["pnpm install", "pnpm add", "pnpm update", "pnpm remove", "pnpm rm", "pnpm uninstall"]
        case "yarn":
            return ["yarn install", "yarn add", "yarn up", "yarn remove"]
        case "bun":
            return ["bun install", "bun add", "bun update", "bun remove"]
        case "uv":
            return ["uv sync", "uv add", "uv remove", "uv pip install", "uv pip uninstall", "uv pip sync", "uv pip compile"]
        case "python":
            return ["pip install", "pip3 install", "python -m pip install", "python3 -m pip install", "pip uninstall", "pip3 uninstall", "python -m pip uninstall", "python3 -m pip uninstall"]
        case "bundler":
            return ["bundle install", "bundle add", "bundle update", "bundle lock", "bundle remove"]
        case "homebrew":
            return ["brew bundle", "brew bundle install", "brew bundle cleanup", "brew bundle dump", "brew update", "brew cleanup", "brew autoremove", "brew tap", "brew tap-new"]
        case "swiftpm":
            return ["swift package update", "swift package resolve"]
        case "go":
            return ["go get", "go mod tidy"]
        case "cargo":
            return ["cargo add", "cargo update", "cargo remove"]
        case "cocoapods":
            return ["pod install", "pod update", "pod repo update", "pod deintegrate"]
        case "carthage":
            return ["carthage bootstrap", "carthage update", "carthage checkout", "carthage build"]
        case "xcodebuild":
            return [
                "xcodebuild build/test/archive before selecting a scheme",
                "xcodebuild -resolvePackageDependencies",
                "xcodebuild -allowProvisioningUpdates",
            ]
        default:
            return []
        }
    }

    private func hasProjectPathVerificationGuard(_ result: ScanResult) -> Bool {
        result.policy.askFirstCommands.contains("running project commands before project path is verified")
    }

    private func markdownPreferredCommands(_ result: ScanResult) -> [String] {
        guard let packageManager = result.project.packageManager,
              let executable = executableName(forPackageManager: packageManager)
        else {
            return result.policy.preferredCommands
        }

        if packageManager == "python",
           result.project.detectedFiles.contains(".venv/bin/python"),
           result.policy.preferredCommands.allSatisfy({ $0.hasPrefix(".venv/bin/python") }) {
            return result.policy.preferredCommands
        }

        if ["npm", "pnpm", "yarn", "bun"].contains(packageManager),
           result.policy.askFirstCommands.contains("running JavaScript commands before node is available") {
            return []
        }

        if ["swiftpm", "xcodebuild"].contains(packageManager),
           result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds") {
            return []
        }

        if projectRelevantVersionCheckGuardApplies(result) {
            return result.policy.preferredCommands.filter {
                isAvailableProjectLocalPreferredCommand($0, result: result)
            }
        }

        let isMissing = selectedExecutableIsMissing(result, executable: executable)

        if isMissing {
            return result.policy.preferredCommands.filter {
                isAvailableProjectLocalPreferredCommand($0, result: result)
            }
        }

        return result.policy.preferredCommands
    }

    private func xcodeToolingNeedsVerification(_ result: ScanResult) -> Bool {
        result.policy.askFirstCommands.contains("running Xcode build commands before xcodebuild is available")
            || result.policy.askFirstCommands.contains("running Xcode build commands before xcodebuild version check succeeds")
            || result.policy.askFirstCommands.contains("Swift/Xcode build commands before xcode-select -p succeeds")
    }

    private func selectedToolVerificationUseLine(_ result: ScanResult, packageManager: String) -> String? {
        if packageManager == "xcodebuild", xcodeToolingNeedsVerification(result) {
            return "Verify Xcode tooling before running Xcode commands."
        }

        if let javaScriptToolLine = javaScriptToolVerificationUseLine(result, packageManager: packageManager) {
            return javaScriptToolLine
        }

        if let missingToolLine = selectedToolMissingUseLine(result, packageManager: packageManager) {
            return missingToolLine
        }

        guard projectRelevantVersionCheckGuardApplies(result) else {
            return nil
        }

        let guards: [(command: String, executable: String, label: String)] = [
            ("running JavaScript commands before node version check succeeds", "node", "JavaScript"),
            ("running \(packageManager) commands before \(packageManager) version check succeeds", packageManager, packageManager),
            ("running Bundler commands before ruby version check succeeds", "ruby", "Bundler"),
            ("running Bundler commands before bundle version check succeeds", "bundle", "Bundler"),
            ("running SwiftPM commands before swift version check succeeds", "swift", "SwiftPM"),
            ("running Go commands before go version check succeeds", "go", "Go"),
            ("running Cargo commands before cargo version check succeeds", "cargo", "Cargo"),
            ("running Homebrew Bundle commands before brew version check succeeds", "brew", "Homebrew Bundle"),
            ("running CocoaPods commands before pod version check succeeds", "pod", "CocoaPods"),
            ("running Carthage commands before carthage version check succeeds", "carthage", "Carthage"),
            ("running Python commands before python3 version check succeeds", "python3", "Python")
        ]

        guard let match = guards.first(where: { result.policy.askFirstCommands.contains($0.command) }) else {
            return nil
        }

        return "Verify `\(match.executable)` before running \(match.label) commands."
    }

    private func packageManagerUsePhrase(_ packageManager: String, result: ScanResult) -> String {
        if packageManager == "python",
           result.project.detectedFiles.contains(".venv/bin/python") {
            return "project Python (`.venv/bin/python`)"
        }

        switch packageManager {
        case "swiftpm":
            return "SwiftPM (`swift`)"
        case "bundler":
            return "Bundler (`bundle`)"
        case "homebrew":
            return "Homebrew Bundle (`brew`)"
        case "cocoapods":
            return "CocoaPods (`pod`)"
        default:
            return "`\(packageManager)`"
        }
    }

    private func javaScriptToolVerificationUseLine(_ result: ScanResult, packageManager: String) -> String? {
        guard ["npm", "pnpm", "yarn", "bun"].contains(packageManager) else {
            return nil
        }

        let nodeNeedsVerification = result.policy.askFirstCommands.contains("running JavaScript commands before node is available")
            || result.policy.askFirstCommands.contains("running JavaScript commands before node version check succeeds")
        let packageManagerNeedsVerification = result.policy.askFirstCommands.contains("running \(packageManager) commands before \(packageManager) is available")
            || result.policy.askFirstCommands.contains("running \(packageManager) commands before \(packageManager) version check succeeds")

        switch (nodeNeedsVerification, packageManagerNeedsVerification) {
        case (true, true):
            return "Verify `node` and `\(packageManager)` before running JavaScript commands."
        case (true, false):
            return "Verify `node` before running JavaScript commands."
        case (false, true):
            return "Verify `\(packageManager)` before running \(packageManager) commands."
        case (false, false):
            return nil
        }
    }

    private func selectedToolMissingUseLine(_ result: ScanResult, packageManager: String) -> String? {
        let guards: [(command: String, executable: String, label: String)] = [
            ("running JavaScript commands before node is available", "node", "JavaScript"),
            ("running \(packageManager) commands before \(packageManager) is available", packageManager, packageManager),
            ("running Bundler commands before bundle is available", "bundle", "Bundler"),
            ("running SwiftPM commands before swift is available", "swift", "SwiftPM"),
            ("running Go commands before go is available", "go", "Go"),
            ("running Cargo commands before cargo is available", "cargo", "Cargo"),
            ("running Homebrew Bundle commands before brew is available", "brew", "Homebrew Bundle"),
            ("running CocoaPods commands before pod is available", "pod", "CocoaPods"),
            ("running Carthage commands before carthage is available", "carthage", "Carthage"),
            ("running Python commands before python3 is available", "python3", "Python")
        ]

        guard let match = guards.first(where: { result.policy.askFirstCommands.contains($0.command) }) else {
            return nil
        }

        return "Verify `\(match.executable)` before running \(match.label) commands."
    }

    private func projectRelevantVersionCheckGuardApplies(_ result: ScanResult) -> Bool {
        result.policy.askFirstCommands.contains { command in
            let lowercasedCommand = command.lowercased()

            return command.contains("version check succeeds")
                && (
                    lowercasedCommand.contains("running javascript commands")
                        || lowercasedCommand.contains("running swiftpm commands")
                        || lowercasedCommand.contains("running go commands")
                        || lowercasedCommand.contains("running cargo commands")
                        || lowercasedCommand.contains("running python commands")
                        || lowercasedCommand.contains("running bundler commands")
                        || lowercasedCommand.contains("running homebrew bundle commands")
                        || lowercasedCommand.contains("running cocoapods commands")
                        || lowercasedCommand.contains("running carthage commands")
                        || lowercasedCommand.contains("running xcode build commands")
                        || result.project.packageManager.map { lowercasedCommand.contains("running \($0) commands") } == true
                )
        }
    }

    private func selectedExecutableIsMissing(_ result: ScanResult, executable: String) -> Bool {
        result.tools.resolvedPaths
            .first(where: { $0.name == executable })?
            .paths
            .isEmpty ?? true
    }

    private func isAvailableProjectLocalPreferredCommand(_ command: String, result: ScanResult) -> Bool {
        let executable = command
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init)

        switch executable {
        case ".venv/bin/python":
            return result.project.detectedFiles.contains(".venv/bin/python")
        default:
            return false
        }
    }

    private func prioritizedForbiddenCommands(_ result: ScanResult) -> [String] {
        var commands: [String] = []

        append("sudo", to: &commands, from: result.policy.forbiddenCommands)
        append("destructive file deletion outside the selected project", to: &commands, from: result.policy.forbiddenCommands)

        if hasSSHPrivateKeyFile(result.project) {
            append("read private keys", to: &commands, from: result.policy.forbiddenCommands)
        }

        if hasSecretDotEnvFile(result.project) || result.project.detectedFiles.contains(".env.example") {
            append("read .env values", to: &commands, from: result.policy.forbiddenCommands)
        }

        if hasSecretEnvrcFile(result.project) || result.project.detectedFiles.contains(".envrc.example") {
            append("read .envrc values", to: &commands, from: result.policy.forbiddenCommands)
        }

        if hasSecretDotEnvFile(result.project) || hasSecretEnvrcFile(result.project) {
            append("load secret environment files", to: &commands, from: result.policy.forbiddenCommands)
            append("render Docker Compose config when secret environment files exist", to: &commands, from: result.policy.forbiddenCommands)
        }

        if hasNetrcFile(result.project) {
            append("read .netrc values", to: &commands, from: result.policy.forbiddenCommands)
        }

        if hasPackageManagerAuthConfig(result.project) {
            append("read package manager auth config values", to: &commands, from: result.policy.forbiddenCommands)
        }

        if hasProjectCloudOrContainerCredentialFiles(result.project) {
            append("read local cloud and container credential files", to: &commands, from: result.policy.forbiddenCommands)
        }

        append("project copy, sync, or archive without excluding secret-bearing files", to: &commands, from: result.policy.forbiddenCommands)

        if !hasSSHPrivateKeyFile(result.project) {
            append("read private keys", to: &commands, from: result.policy.forbiddenCommands)
        }

        if !hasProjectCloudOrContainerCredentialFiles(result.project) {
            append("read local cloud and container credential files", to: &commands, from: result.policy.forbiddenCommands)
        }

        append("dump environment variables", to: &commands, from: result.policy.forbiddenCommands)
        append("read clipboard contents", to: &commands, from: result.policy.forbiddenCommands)
        append("read shell history", to: &commands, from: result.policy.forbiddenCommands)
        append("read browser or mail data", to: &commands, from: result.policy.forbiddenCommands)
        append("remote script execution through curl or wget", to: &commands, from: result.policy.forbiddenCommands)

        for command in result.policy.forbiddenCommands where !commands.contains(command) {
            commands.append(command)
        }

        return commands
    }

    private func append(_ command: String, to commands: inout [String], from source: [String]) {
        guard source.contains(command), !commands.contains(command) else { return }
        commands.append(command)
    }

    private func hasSecretDotEnvFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            file == ".env" || (file.hasPrefix(".env.") && file != ".env.example")
        }
    }

    private func hasSecretEnvrcFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            file == ".envrc" || (file.hasPrefix(".envrc.") && file != ".envrc.example")
        }
    }

    private func hasPackageManagerAuthConfig(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            file == ".npmrc"
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
        }
    }

    private func hasProjectCloudOrContainerCredentialFiles(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            file == ".aws/credentials"
                || file == ".aws/config"
                || file == ".config/gcloud/application_default_credentials.json"
                || file == ".docker/config.json"
                || file == ".kube/config"
        }
    }

    private func hasNetrcFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains(".netrc")
    }

    private func hasSSHPrivateKeyFile(_ project: ProjectInfo) -> Bool {
        project.detectedFiles.contains { file in
            isSSHPrivateKeyFilename(file)
        }
    }

    private func hasDetectedSecretValueFile(_ project: ProjectInfo) -> Bool {
        hasSecretDotEnvFile(project)
            || hasSecretEnvrcFile(project)
            || hasNetrcFile(project)
            || hasPackageManagerAuthConfig(project)
            || hasProjectCloudOrContainerCredentialFiles(project)
            || hasSSHPrivateKeyFile(project)
    }

    private func secretBearingFileGuidance(files: [String]) -> String {
        guard !files.isEmpty else { return "" }

        return """
        ## If Secret-Bearing Files Are Detected
        - Detected secret-bearing paths: \(summarize(files)).
        - Before recursive search, copy, sync, or archive commands, review exclusions for these paths.
        - For necessary broad search, start with exclusion-aware `rg`: `rg <pattern> \(searchExclusionGlobs(for: files).joined(separator: " "))`.
        - Apply equivalent exclusions before broad `grep -R`, `git grep`, copy, sync, or archive commands.
        - Prefer targeted project inspection over broad `rg`, `grep -R`, `git grep`, `rsync`, `tar`, `zip`, or `git archive` commands.
        """
    }

    private func searchExclusionGlobs(for files: [String]) -> [String] {
        var globs: [String] = []

        func append(_ glob: String) {
            guard !globs.contains(glob) else { return }
            globs.append(glob)
        }

        for file in files {
            if file == ".env" {
                append(".env")
                append(".env.*")
            } else if file == ".envrc" {
                append(".envrc")
                append(".envrc.*")
            } else {
                append(file)
            }
        }

        return globs.prefix(6).map { "--glob '!\($0)'" }
    }

    private func secretValueFiles(_ project: ProjectInfo) -> [String] {
        project.detectedFiles
            .filter { file in
                hasSecretDotEnvFilename(file)
                    || hasSecretEnvrcFilename(file)
                    || file == ".netrc"
                    || isPackageManagerAuthConfigFile(file)
                    || isProjectCloudOrContainerCredentialFile(file)
                    || isSSHPrivateKeyFilename(file)
            }
            .sorted()
    }

    private func summarize(_ values: [String], limit: Int = 6) -> String {
        guard values.count > limit else {
            return values.joined(separator: ", ")
        }

        return values.prefix(limit).joined(separator: ", ")
            + ", and \(values.count - limit) more"
    }

    private func isSSHPrivateKeyFilename(_ file: String) -> Bool {
        let basename = URL(fileURLWithPath: file).lastPathComponent.lowercased()
        guard !basename.hasSuffix(".pub") else { return false }

        if ["id_rsa", "id_dsa", "id_ecdsa", "id_ed25519"].contains(basename) {
            return true
        }

        return [".pem", ".key", ".p8", ".p12", ".ppk"].contains { basename.hasSuffix($0) }
    }

    private func hasSecretDotEnvFilename(_ file: String) -> Bool {
        file == ".env" || (file.hasPrefix(".env.") && file != ".env.example")
    }

    private func hasSecretEnvrcFilename(_ file: String) -> Bool {
        file == ".envrc" || (file.hasPrefix(".envrc.") && file != ".envrc.example")
    }

    private func isPackageManagerAuthConfigFile(_ file: String) -> Bool {
        file == ".npmrc"
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
    }

    private func isProjectCloudOrContainerCredentialFile(_ file: String) -> Bool {
        file == ".aws/credentials"
            || file == ".aws/config"
            || file == ".config/gcloud/application_default_credentials.json"
            || file == ".docker/config.json"
            || file == ".kube/config"
    }

    private func agentRelevantCommandNames(_ result: ScanResult) -> Set<String> {
        var names = Set<String>()

        if let packageManager = result.project.packageManager,
           let executable = executableName(forPackageManager: packageManager) {
            names.insert(executable)

            if ["npm", "pnpm", "yarn", "bun"].contains(packageManager) {
                names.insert("node")
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

        if let packageManager = result.project.packageManager,
           ["swiftpm", "xcodebuild"].contains(packageManager) {
            names.insert("xcode-select")
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
}
