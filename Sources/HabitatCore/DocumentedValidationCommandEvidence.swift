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
        guard let firstClaim = claims.first else { return [] }
        let claimedWorkflow = workflow(for: firstClaim.command)
        let actualWorkflow = project.packageManager

        if let claimedWorkflow, claimedWorkflow == actualWorkflow {
            return alignedAnnotations(claim: firstClaim)
        }

        if claimedWorkflow != nil {
            return conflictingAnnotations(claim: firstClaim)
        }

        return []
    }

    private func alignedAnnotations(claim: ValidationCommandClaim) -> [String] {
        let workflow = workflowName(project.packageManager)
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
        if command.hasPrefix("bundle ") { return "bundler" }
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
        case "bundler":
            return "Bundler"
        case "xcodebuild":
            return "Xcode"
        default:
            return "unknown"
        }
    }
}
