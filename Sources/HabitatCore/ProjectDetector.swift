import Foundation

public struct ProjectDetector {
    public init() {}

    private let candidateFiles = [
        "package.json",
        "package-lock.json",
        "pnpm-lock.yaml",
        "pnpm-workspace.yaml",
        "yarn.lock",
        "bun.lock",
        "bun.lockb",
        "pyproject.toml",
        "requirements.txt",
        "requirements-dev.txt",
        "uv.lock",
        "Pipfile",
        "Pipfile.lock",
        ".venv",
        ".venv/bin/python",
        "Gemfile",
        "Gemfile.lock",
        "go.mod",
        "Cargo.toml",
        "Package.swift",
        "Package.resolved",
        "Podfile",
        "Podfile.lock",
        "Cartfile",
        "Cartfile.resolved",
        "Brewfile",
        "mise.toml",
        ".tool-versions",
        ".python-version",
        ".node-version",
        ".nvmrc",
        ".npmrc",
        ".pnpmrc",
        ".yarnrc",
        ".yarnrc.yml",
        ".env",
        ".env.local",
        ".env.development",
        ".env.development.local",
        ".env.test",
        ".env.test.local",
        ".env.production",
        ".env.production.local",
        ".env.example",
        ".envrc",
        ".envrc.local",
        ".envrc.example",
        "id_rsa",
        "id_dsa",
        "id_ecdsa",
        "id_ed25519",
        "README.md",
    ]

    public func detect(projectURL: URL) -> ProjectInfo {
        let detectedFiles = detectedProjectFiles(projectURL: projectURL)
        let packageJSON = packageJSONMetadata(projectURL.appendingPathComponent("package.json"))
        let toolVersions = toolVersionsMetadata(projectURL.appendingPathComponent(".tool-versions"))
        let packageManager = detectPackageManager(files: detectedFiles, declaredPackageManager: packageJSON.declaredPackageManager)

        return ProjectInfo(
            detectedFiles: detectedFiles,
            packageManager: packageManager,
            packageManagerVersion: packageManagerVersion(packageManager: packageManager, packageJSON: packageJSON),
            packageScripts: packageJSON.scripts,
            runtimeHints: RuntimeHints(
                node: firstAvailableLineIfSafe(
                    projectURL.appendingPathComponent(".nvmrc"),
                    projectURL.appendingPathComponent(".node-version")
                ) ?? toolVersions.node ?? packageJSON.node,
                python: firstLineIfSafe(projectURL.appendingPathComponent(".python-version")) ?? toolVersions.python
            ),
            declaredPackageManager: packageJSON.declaredPackageManager?.name,
            declaredPackageManagerVersion: packageJSON.declaredPackageManager?.version
        )
    }

    private func detectedProjectFiles(projectURL: URL) -> [String] {
        let manager = FileManager.default
        let explicitFiles = candidateFiles.filter {
            manager.fileExists(atPath: projectURL.appendingPathComponent($0).path)
        }
        let directoryEntries = (try? manager.contentsOfDirectory(atPath: projectURL.path)) ?? []
        let xcodeProjectContainers = directoryEntries
            .filter(isXcodeProjectContainer)
            .sorted()
        let extraSecretEnvironmentFiles = directoryEntries
            .filter(isSecretEnvironmentFilename)
            .filter { !candidateFiles.contains($0) }
            .sorted()

        return orderedUnique(explicitFiles + xcodeProjectContainers + extraSecretEnvironmentFiles)
    }

    private func detectPackageManager(files: [String], declaredPackageManager: DeclaredPackageManager?) -> String? {
        if files.contains("pnpm-lock.yaml") { return "pnpm" }
        if files.contains("yarn.lock") { return "yarn" }
        if files.contains("bun.lock") || files.contains("bun.lockb") { return "bun" }
        if files.contains("package-lock.json") { return "npm" }
        if files.contains("package.json"), let declaredPackageManager {
            return declaredPackageManager.name
        }
        if files.contains("pnpm-workspace.yaml") { return "pnpm" }
        if files.contains("package.json") { return "npm" }
        if files.contains("Podfile") || files.contains("Podfile.lock") { return "cocoapods" }
        if files.contains("Cartfile") || files.contains("Cartfile.resolved") { return "carthage" }
        if hasXcodeProjectContainer(files) { return "xcodebuild" }
        if files.contains("Package.swift") || files.contains("Package.resolved") { return "swiftpm" }
        if files.contains("go.mod") { return "go" }
        if files.contains("Cargo.toml") { return "cargo" }
        if files.contains("Brewfile") { return "homebrew" }
        if files.contains("uv.lock") { return "uv" }
        if files.contains("pyproject.toml")
            || files.contains("requirements.txt")
            || files.contains("requirements-dev.txt")
            || files.contains("Pipfile")
            || files.contains("Pipfile.lock") { return "python" }
        if files.contains("Gemfile") || files.contains("Gemfile.lock") { return "bundler" }
        return nil
    }

    private func isSecretEnvironmentFilename(_ name: String) -> Bool {
        name == ".env"
            || (name.hasPrefix(".env.") && name != ".env.example")
            || name == ".envrc"
            || (name.hasPrefix(".envrc.") && name != ".envrc.example")
    }

    private func isXcodeProjectContainer(_ name: String) -> Bool {
        name.hasSuffix(".xcworkspace") || name.hasSuffix(".xcodeproj")
    }

    private func hasXcodeProjectContainer(_ files: [String]) -> Bool {
        files.contains(where: isXcodeProjectContainer)
    }

    private func packageJSONMetadata(_ url: URL) -> PackageJSONMetadata {
        guard FileManager.default.fileExists(atPath: url.path) else { return .empty }
        guard fileSize(at: url) <= 512 * 1024 else { return .empty }
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return .empty
        }

        let declaredPackageManager = (json["packageManager"] as? String)
            .flatMap(declaredPackageManager(from:))
        let scripts = (json["scripts"] as? [String: Any])?
            .compactMap { key, value in value is String ? key : nil }
            .sorted() ?? []
        let volta = voltaMetadata(from: json["volta"])
        let engines = enginesMetadata(from: json["engines"])

        return PackageJSONMetadata(
            declaredPackageManager: declaredPackageManager,
            scripts: scripts,
            node: volta.node ?? engines.node,
            packageManagerVersions: volta.packageManagerVersions
        )
    }

    private func packageManagerVersion(packageManager: String?, packageJSON: PackageJSONMetadata) -> String? {
        guard let packageManager else { return nil }

        if packageJSON.declaredPackageManager?.name == packageManager,
           let version = packageJSON.declaredPackageManager?.version {
            return version
        }

        return packageJSON.packageManagerVersions[packageManager]
    }

    private func toolVersionsMetadata(_ url: URL) -> ToolVersionsMetadata {
        guard FileManager.default.fileExists(atPath: url.path) else { return .empty }
        guard fileSize(at: url) <= 64 * 1024 else { return .empty }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return .empty }

        var node: String?
        var python: String?

        for rawLine in content.split(whereSeparator: \.isNewline) {
            let line = rawLine
                .split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
                .first?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let parts = line.split(whereSeparator: \.isWhitespace).map(String.init)
            guard parts.count >= 2 else { continue }

            switch parts[0] {
            case "node", "nodejs":
                if node == nil {
                    node = parts[1]
                }
            case "python":
                if python == nil {
                    python = parts[1]
                }
            default:
                continue
            }
        }

        return ToolVersionsMetadata(node: node, python: python)
    }

    private func declaredPackageManager(from rawPackageManager: String) -> DeclaredPackageManager? {
        let value = rawPackageManager.trimmingCharacters(in: .whitespacesAndNewlines)
        for packageManager in ["pnpm", "yarn", "bun", "npm"] {
            if value == packageManager {
                return DeclaredPackageManager(name: packageManager, version: nil)
            }

            if value.hasPrefix("\(packageManager)@") {
                let version = String(value.dropFirst(packageManager.count + 1))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard !version.isEmpty else { return nil }
                return DeclaredPackageManager(name: packageManager, version: version)
            }
        }

        return nil
    }

    private func voltaMetadata(from rawValue: Any?) -> VoltaMetadata {
        guard let object = rawValue as? [String: Any] else { return .empty }
        let node = normalizedNonEmptyString(object["node"])
        var packageManagerVersions: [String: String] = [:]

        for packageManager in ["npm", "pnpm", "yarn", "bun"] {
            if let version = normalizedNonEmptyString(object[packageManager]) {
                packageManagerVersions[packageManager] = version
            }
        }

        return VoltaMetadata(node: node, packageManagerVersions: packageManagerVersions)
    }

    private func enginesMetadata(from rawValue: Any?) -> EnginesMetadata {
        guard let object = rawValue as? [String: Any] else { return .empty }
        return EnginesMetadata(node: normalizedNonEmptyString(object["node"]))
    }

    private func normalizedNonEmptyString(_ value: Any?) -> String? {
        guard let string = value as? String else { return nil }
        let normalized = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalized.isEmpty ? nil : normalized
    }

    private func fileSize(at url: URL) -> UInt64 {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attributes?[.size] as? NSNumber)?.uint64Value ?? UInt64.max
    }

    private func firstAvailableLineIfSafe(_ urls: URL...) -> String? {
        for url in urls {
            if let line = firstLineIfSafe(url) {
                return line
            }
        }

        return nil
    }

    private func firstLineIfSafe(_ url: URL) -> String? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let lastPath = url.lastPathComponent
        guard lastPath == ".nvmrc" || lastPath == ".node-version" || lastPath == ".python-version" else { return nil }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        return content
            .split(whereSeparator: \.isNewline)
            .first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }
}

private struct DeclaredPackageManager {
    let name: String
    let version: String?
}

private struct PackageJSONMetadata {
    static let empty = PackageJSONMetadata(declaredPackageManager: nil, scripts: [], node: nil, packageManagerVersions: [:])

    let declaredPackageManager: DeclaredPackageManager?
    let scripts: [String]
    let node: String?
    let packageManagerVersions: [String: String]
}

private struct ToolVersionsMetadata {
    static let empty = ToolVersionsMetadata(node: nil, python: nil)

    let node: String?
    let python: String?
}

private struct VoltaMetadata {
    static let empty = VoltaMetadata(node: nil, packageManagerVersions: [:])

    let node: String?
    let packageManagerVersions: [String: String]
}

private struct EnginesMetadata {
    static let empty = EnginesMetadata(node: nil)

    let node: String?
}
