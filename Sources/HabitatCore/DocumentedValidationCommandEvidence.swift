public struct DocumentedValidationCommandEvidence {
    public let claims: [ValidationCommandClaim]
    public let project: ProjectInfo
    public let preferredCommands: [String]

    public init(project: ProjectInfo, preferredCommands: [String]) {
        self.claims = project.validationCommandClaims
        self.project = project
        self.preferredCommands = preferredCommands
    }

    public var hasClaims: Bool {
        !claims.isEmpty
    }

    public var agentContextAnnotations: [String] {
        let ordinaryClaims = claims.filter { $0.purpose == .ordinaryLocal }
        let releaseArtifactClaims = claims.filter { $0.purpose == .releaseArtifact }
        let deviceVerificationClaims = claims.filter { $0.purpose == .deviceVerification }
        let environmentCheckClaims = claims.filter { $0.purpose == .environmentCheck }
        let scopedAnnotations = releaseArtifactAnnotations(for: releaseArtifactClaims.first)
            + deviceVerificationAnnotations(for: deviceVerificationClaims.first)
            + environmentCheckAnnotations(for: environmentCheckClaims.first)
        guard let firstClaim = ordinaryClaims.first else {
            return scopedAnnotations
        }

        if let uncertainAnnotations = multipleClaimUncertaintyAnnotations {
            return uncertainAnnotations + scopedAnnotations
        }

        let claimedWorkflow = workflow(for: firstClaim.command)
        let actualWorkflow = project.packageManager

        if let claimedWorkflow, claimedWorkflow == actualWorkflow {
            return alignedAnnotations(claim: firstClaim) + scopedAnnotations
        }

        if claimedWorkflow == "project_script" {
            return projectScriptAnnotations(claim: firstClaim) + scopedAnnotations
        }

        if claimedWorkflow != nil, actualWorkflow == nil {
            return unknownRepositoryWorkflowAnnotations(claim: firstClaim) + scopedAnnotations
        }

        if claimedWorkflow != nil {
            return conflictingAnnotations(claim: firstClaim) + scopedAnnotations
        }

        return scopedAnnotations
    }

    private var multipleClaimUncertaintyAnnotations: [String]? {
        let workflows = uniqueWorkflows(for: claims.filter { $0.purpose == .ordinaryLocal })
        guard workflows.count > 1 else { return nil }

        var lines = [
            "Fact: Project instructions mention multiple validation workflows: \(workflows.map(workflowName).joined(separator: ", ")).",
            "Open uncertainty: Instruction files disagree on local validation; verify the intended command before following one documented claim."
        ]

        if let preferred = preferredValidationCommand {
            lines.append("Hint: Prefer `\(preferred)` only for ordinary local validation when repository facts still support it.")
        }

        return lines
    }

    private func releaseArtifactAnnotations(for claim: ValidationCommandClaim?) -> [String] {
        guard let claim else { return [] }
        return [
            "Fact: Project instructions mention release/artifact validation `\(claim.command)`.",
            "Hint: Keep `\(claim.command)` for release prep or artifact verification, not ordinary local validation."
        ]
    }

    private func deviceVerificationAnnotations(for claim: ValidationCommandClaim?) -> [String] {
        guard let claim else { return [] }
        return [
            "Fact: Project instructions mention device verification `\(claim.command)`; keep it for connected-device checks, not ordinary local validation."
        ]
    }

    private func environmentCheckAnnotations(for claim: ValidationCommandClaim?) -> [String] {
        guard let claim else { return [] }
        return [
            "Fact: Project instructions mention environment check `\(claim.command)`; keep it for setup/preflight checks, not ordinary local validation."
        ]
    }

    private func alignedAnnotations(claim: ValidationCommandClaim) -> [String] {
        let workflow = workflowName(project.packageManager)
        if project.packageManager == "xcodebuild" {
            if let preferred = preferredCommands.first {
                return [
                    "Fact: Project instructions and repository files both support Xcode validation.",
                    "Hint: Start with `\(preferred)` before following documented `\(claim.command)` validation."
                ]
            }

            return [
                "Fact: Project instructions mention Xcode validation and repository files include an Xcode project.",
                "Open uncertainty: Verify Xcode tooling and scheme selection before following documented `\(claim.command)` validation."
            ]
        }

        let preferred = preferredValidationCommand ?? claim.command
        return [
            "Fact: Project instructions and repository files both support \(workflow) validation.",
            "Hint: Prefer `\(preferred)` for local validation."
        ]
    }

    private func conflictingAnnotations(claim: ValidationCommandClaim) -> [String] {
        var lines = [
            repositoryFactLine,
            "Warning: Project instructions mention `\(claim.command)`, but repository facts select \(workflowName(project.packageManager)) validation."
        ]

        if let preferred = preferredValidationCommand {
            lines.append("Hint: Prefer `\(preferred)` unless the task explicitly targets generated docs or external examples.")
        } else {
            lines.append("Hint: Verify the documented command before using it for local validation.")
        }

        return lines
    }

    private func projectScriptAnnotations(claim: ValidationCommandClaim) -> [String] {
        var lines = [
            "Fact: Project instructions mention project-local validation script `\(claim.command)`."
        ]

        let isKnownPreferredScript = ProjectLocalValidationScript.knownValidationCommands.contains(claim.command)
            && preferredCommands.contains(claim.command)

        if isKnownPreferredScript {
            lines.append("Hint: Prefer `\(claim.command)` when repository docs make it the validation entrypoint.")
            return lines
        }

        if let actualWorkflow = project.packageManager {
            lines.append("Open uncertainty: Verify whether the script wraps \(workflowName(actualWorkflow)) validation before using raw package-manager commands.")
        } else {
            lines.append("Open uncertainty: Verify the project-local validation script before using it as the local check.")
        }

        if preferredCommands.contains(claim.command) {
            lines.append("Hint: Prefer `\(claim.command)` when repository docs make it the validation entrypoint.")
        } else {
            lines.append("Hint: Do not prefer `\(claim.command)` until the script exists and is executable.")
        }
        return lines
    }

    private func unknownRepositoryWorkflowAnnotations(claim: ValidationCommandClaim) -> [String] {
        [
            repositoryFactLine,
            "Open uncertainty: Project instructions mention `\(claim.command)`, but repository facts do not confirm that validation workflow.",
            "Hint: Verify the documented command before using it for local validation."
        ]
    }

    private var repositoryFactLine: String {
        if project.packageManager == "swiftpm" {
            if !project.detectedFiles.contains("package.json") {
                return "Fact: `Package.swift` is present and `package.json` is absent."
            }

            return "Fact: `Package.swift` is present."
        }

        if let packageManager = project.packageManager {
            return "Fact: Repository files select \(workflowName(packageManager)) validation."
        }

        return "Fact: Repository files do not identify a primary validation workflow."
    }

    private var preferredValidationCommand: String? {
        preferredCommands.first { command in
            command.contains("test")
                || command.contains("build")
                || command.contains("pytest")
        } ?? preferredCommands.first
    }

    private func uniqueWorkflows(for claims: [ValidationCommandClaim]) -> [String] {
        claims.compactMap { workflow(for: $0.command) }
            .reduce(into: [String]()) { workflows, workflow in
                if !workflows.contains(workflow) {
                    workflows.append(workflow)
                }
            }
    }

    private func workflow(for command: String) -> String? {
        if command.hasPrefix("swift ") { return "swiftpm" }
        if command.hasPrefix("npm ") { return "npm" }
        if command.hasPrefix("pnpm ") { return "pnpm" }
        if command.hasPrefix("yarn ") { return "yarn" }
        if command.hasPrefix("bun ") { return "bun" }
        if command.hasPrefix("python ") || command.hasPrefix("python3 ") { return "python" }
        if command.hasPrefix("uv ") { return "uv" }
        if command.hasPrefix("go ") { return "go" }
        if command.hasPrefix("cargo ") { return "cargo" }
        if command.hasPrefix("./gradlew ") { return "gradle" }
        if ProjectLocalValidationScript.isCommand(command) { return "project_script" }
        if command.hasPrefix("bundle ") { return "bundler" }
        if command.hasPrefix("xcodebuild ") { return "xcodebuild" }
        return nil
    }

    private func workflowName(_ workflow: String?) -> String {
        switch workflow {
        case "swiftpm":
            return "SwiftPM"
        case "npm":
            return "npm"
        case "pnpm":
            return "pnpm"
        case "yarn":
            return "yarn"
        case "bun":
            return "Bun"
        case "python":
            return "Python"
        case "uv":
            return "uv"
        case "go":
            return "Go"
        case "cargo":
            return "Cargo"
        case "gradle":
            return "Gradle"
        case "bundler":
            return "Bundler"
        case "xcodebuild":
            return "Xcode"
        case "project_script":
            return "project-local script"
        default:
            return "unknown"
        }
    }
}
