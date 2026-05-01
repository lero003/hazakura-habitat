import Foundation

public struct ProjectDetector {
    public init() {}

    private let candidateFiles = [
        "package.json",
        "package-lock.json",
        "npm-shrinkwrap.json",
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
        ".mise.toml",
        ".tool-versions",
        ".python-version",
        ".ruby-version",
        ".node-version",
        ".nvmrc",
        ".npmrc",
        ".pnpmrc",
        ".yarnrc",
        ".yarnrc.yml",
        ".pypirc",
        "pip.conf",
        ".gem/credentials",
        ".bundle/config",
        ".cargo/credentials.toml",
        ".cargo/credentials",
        "auth.json",
        ".composer/auth.json",
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
        ".netrc",
        "id_rsa",
        "id_dsa",
        "id_ecdsa",
        "id_ed25519",
        ".ssh/id_rsa",
        ".ssh/id_dsa",
        ".ssh/id_ecdsa",
        ".ssh/id_ed25519",
        "README.md",
    ]

    public func detect(projectURL: URL) -> ProjectInfo {
        let detectedFiles = detectedProjectFiles(projectURL: projectURL)
        let symlinkedFiles = symlinkedProjectFiles(projectURL: projectURL, detectedFiles: detectedFiles)
        let unsafeRuntimeHintFiles = unsafeRuntimeHintFiles(projectURL: projectURL, detectedFiles: detectedFiles, symlinkedFiles: symlinkedFiles)
        let packageJSON = packageJSONMetadata(projectURL.appendingPathComponent("package.json"))
        let toolVersions = toolVersionsMetadata(projectURL.appendingPathComponent(".tool-versions"))
        let miseToml = miseTomlMetadata(projectURL: projectURL)
        let packageManagerFiles = packageManagerSelectionFiles(detectedFiles: detectedFiles, symlinkedFiles: symlinkedFiles)
        let packageManager = detectPackageManager(files: packageManagerFiles, declaredPackageManager: packageJSON.declaredPackageManager)
        let packageManagerVersion = packageManagerVersion(
            packageManager: packageManager,
            packageJSON: packageJSON,
            toolVersions: toolVersions,
            miseToml: miseToml.metadata,
            miseTomlSource: miseToml.source
        )

        return ProjectInfo(
            detectedFiles: detectedFiles,
            symlinkedFiles: symlinkedFiles,
            unsafeRuntimeHintFiles: unsafeRuntimeHintFiles,
            unsafePackageMetadataFields: packageJSON.unsafeMetadataFields,
            packageManager: packageManager,
            packageManagerVersion: packageManagerVersion.version,
            packageManagerVersionSource: packageManagerVersion.source,
            packageScripts: packageJSON.scripts,
            runtimeHints: RuntimeHints(
                node: firstAvailableLineIfSafe(
                    projectURL.appendingPathComponent(".nvmrc"),
                    projectURL.appendingPathComponent(".node-version")
                ) ?? toolVersions.node ?? miseToml.metadata.node ?? packageJSON.node,
                python: firstLineIfSafe(projectURL.appendingPathComponent(".python-version")) ?? toolVersions.python ?? miseToml.metadata.python,
                ruby: firstLineIfSafe(projectURL.appendingPathComponent(".ruby-version")) ?? toolVersions.ruby ?? miseToml.metadata.ruby
            ),
            declaredPackageManager: packageJSON.declaredPackageManager?.name,
            declaredPackageManagerVersion: packageJSON.declaredPackageManager?.version
        )
    }

    private func detectedProjectFiles(projectURL: URL) -> [String] {
        let manager = FileManager.default
        let explicitFiles = candidateFiles.filter {
            guard !hasSymbolicLinkAncestor(relativePath: $0, projectURL: projectURL) else {
                return false
            }

            let path = projectURL.appendingPathComponent($0).path
            if $0 == ".venv/bin/python" {
                return manager.isExecutableFile(atPath: path)
            }

            return manager.fileExists(atPath: path)
        }
        let directoryEntries = (try? manager.contentsOfDirectory(atPath: projectURL.path)) ?? []
        let xcodeProjectContainers = directoryEntries
            .filter(isXcodeProjectContainer)
            .sorted()
        let extraSecretEnvironmentFiles = directoryEntries
            .filter(isSecretEnvironmentFilename)
            .filter { !candidateFiles.contains($0) }
            .sorted()
        let extraPrivateKeyFiles = privateKeyFiles(projectURL: projectURL, directoryEntries: directoryEntries)

        return orderedUnique(explicitFiles + xcodeProjectContainers + extraSecretEnvironmentFiles + extraPrivateKeyFiles)
    }

    private func detectPackageManager(files: [String], declaredPackageManager: DeclaredPackageManager?) -> String? {
        if files.contains("pnpm-lock.yaml") { return "pnpm" }
        if files.contains("pnpm-workspace.yaml") { return "pnpm" }
        if files.contains("yarn.lock") { return "yarn" }
        if files.contains("bun.lock") || files.contains("bun.lockb") { return "bun" }
        if files.contains("package-lock.json") || files.contains("npm-shrinkwrap.json") { return "npm" }
        if files.contains("package.json"), let declaredPackageManager {
            return declaredPackageManager.name
        }
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

    private func packageManagerSelectionFiles(detectedFiles: [String], symlinkedFiles: [String]) -> [String] {
        let symlinked = Set(symlinkedFiles)
        return detectedFiles.filter { file in
            !(symlinked.contains(file) && isPackageManagerSelectionSignal(file))
        }
    }

    private func isPackageManagerSelectionSignal(_ file: String) -> Bool {
        switch file {
        case "package.json",
             "package-lock.json",
             "npm-shrinkwrap.json",
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
             "Brewfile":
            return true
        default:
            return isXcodeProjectContainer(file)
        }
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

    private func privateKeyFiles(projectURL: URL, directoryEntries: [String]) -> [String] {
        let topLevelPrivateKeyFiles = directoryEntries
            .filter(isPrivateKeyFilename)

        let sshDirectoryURL = projectURL.appendingPathComponent(".ssh")
        guard !isSymbolicLink(sshDirectoryURL) else {
            return topLevelPrivateKeyFiles.sorted()
        }

        let sshDirectoryEntries = (try? FileManager.default.contentsOfDirectory(atPath: sshDirectoryURL.path)) ?? []
        let sshPrivateKeyFiles = sshDirectoryEntries
            .filter(isPrivateKeyFilename)
            .map { ".ssh/\($0)" }

        return (topLevelPrivateKeyFiles + sshPrivateKeyFiles).sorted()
    }

    private func symlinkedProjectFiles(projectURL: URL, detectedFiles: [String]) -> [String] {
        let detectedSymlinks = detectedFiles.filter {
            isSymbolicLink(projectURL.appendingPathComponent($0))
        }

        let ancestorSymlinks = candidateFiles.compactMap {
            firstSymbolicLinkAncestor(relativePath: $0, projectURL: projectURL)
        }

        return orderedUnique(detectedSymlinks + ancestorSymlinks).sorted()
    }

    private func unsafeRuntimeHintFiles(projectURL: URL, detectedFiles: [String], symlinkedFiles: [String]) -> [String] {
        let symlinked = Set(symlinkedFiles)
        return [".nvmrc", ".node-version", ".python-version", ".ruby-version"].filter { file in
            detectedFiles.contains(file)
                && !symlinked.contains(file)
                && firstLineIfSafe(projectURL.appendingPathComponent(file)) == nil
        }
    }

    private func isPrivateKeyFilename(_ name: String) -> Bool {
        let basename = URL(fileURLWithPath: name).lastPathComponent.lowercased()
        guard !basename.hasSuffix(".pub") else { return false }

        if ["id_rsa", "id_dsa", "id_ecdsa", "id_ed25519"].contains(basename) {
            return true
        }

        return [".pem", ".key", ".p8", ".p12", ".ppk"].contains { basename.hasSuffix($0) }
    }

    private func hasXcodeProjectContainer(_ files: [String]) -> Bool {
        files.contains(where: isXcodeProjectContainer)
    }

    private func packageJSONMetadata(_ url: URL) -> PackageJSONMetadata {
        guard FileManager.default.fileExists(atPath: url.path) else { return .empty }
        guard !isSymbolicLink(url) else { return .empty }
        guard fileSize(at: url) <= 512 * 1024 else { return .empty }
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return .empty
        }

        var unsafeMetadataFields: [String] = []
        let declaredPackageManagerMetadata: DeclaredPackageManager?
        if let rawPackageManager = json["packageManager"] as? String {
            let metadata = declaredPackageManager(from: rawPackageManager)
            if metadata.versionWasUnsafe {
                unsafeMetadataFields.append("package.json packageManager")
            }
            declaredPackageManagerMetadata = metadata.declaredPackageManager
        } else {
            declaredPackageManagerMetadata = nil
        }
        let scripts = (json["scripts"] as? [String: Any])?
            .compactMap { key, value in value is String ? key : nil }
            .sorted() ?? []
        let volta = voltaMetadata(from: json["volta"])
        let engines = enginesMetadata(from: json["engines"])
        unsafeMetadataFields.append(contentsOf: volta.unsafeMetadataFields)
        unsafeMetadataFields.append(contentsOf: engines.unsafeMetadataFields)

        return PackageJSONMetadata(
            declaredPackageManager: declaredPackageManagerMetadata,
            scripts: scripts,
            node: volta.node ?? engines.node,
            packageManagerVersions: volta.packageManagerVersions,
            unsafeMetadataFields: orderedUnique(unsafeMetadataFields)
        )
    }

    private func packageManagerVersion(packageManager: String?, packageJSON: PackageJSONMetadata, toolVersions: ToolVersionsMetadata, miseToml: ToolVersionsMetadata, miseTomlSource: String?) -> PackageManagerVersionInfo {
        guard let packageManager else { return .empty }

        if packageJSON.declaredPackageManager?.name == packageManager,
           let version = packageJSON.declaredPackageManager?.version {
            return PackageManagerVersionInfo(version: version, source: "package.json")
        }

        if let version = packageJSON.packageManagerVersions[packageManager] {
            return PackageManagerVersionInfo(version: version, source: "package.json")
        }

        if let version = toolVersions.packageManagerVersions[packageManager] {
            return PackageManagerVersionInfo(version: version, source: ".tool-versions")
        }

        if let version = miseToml.packageManagerVersions[packageManager] {
            return PackageManagerVersionInfo(version: version, source: miseTomlSource ?? "mise.toml")
        }

        return .empty
    }

    private func miseTomlMetadata(projectURL: URL) -> SourcedToolVersionsMetadata {
        for filename in ["mise.toml", ".mise.toml"] {
            let metadata = miseTomlMetadata(projectURL.appendingPathComponent(filename))
            if !metadata.isEmpty {
                return SourcedToolVersionsMetadata(metadata: metadata, source: filename)
            }
        }

        return .empty
    }

    private func toolVersionsMetadata(_ url: URL) -> ToolVersionsMetadata {
        guard FileManager.default.fileExists(atPath: url.path) else { return .empty }
        guard !isSymbolicLink(url) else { return .empty }
        guard fileSize(at: url) <= 64 * 1024 else { return .empty }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return .empty }

        var node: String?
        var python: String?
        var ruby: String?
        var packageManagerVersions: [String: String] = [:]

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
            case "ruby":
                if ruby == nil {
                    ruby = parts[1]
                }
            case "npm", "pnpm", "yarn", "bun":
                if packageManagerVersions[parts[0]] == nil {
                    packageManagerVersions[parts[0]] = normalizedPackageManagerVersion(parts[1])
                }
            default:
                continue
            }
        }

        return ToolVersionsMetadata(
            node: node,
            python: python,
            ruby: ruby,
            packageManagerVersions: packageManagerVersions
        )
    }

    private func miseTomlMetadata(_ url: URL) -> ToolVersionsMetadata {
        guard FileManager.default.fileExists(atPath: url.path) else { return .empty }
        guard !isSymbolicLink(url) else { return .empty }
        guard fileSize(at: url) <= 64 * 1024 else { return .empty }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return .empty }

        var node: String?
        var python: String?
        var ruby: String?
        var packageManagerVersions: [String: String] = [:]
        var inToolsSection = false

        for rawLine in content.split(whereSeparator: \.isNewline) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#") else { continue }

            if line.hasPrefix("[") {
                inToolsSection = tomlSectionName(from: line) == "tools"
                continue
            }

            guard inToolsSection else { continue }
            let parts = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { continue }

            let tool = parts[0]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            guard let version = tomlStringVersion(from: String(parts[1])) else { continue }

            switch tool {
            case "node", "nodejs":
                if node == nil {
                    node = version
                }
            case "python":
                if python == nil {
                    python = version
                }
            case "ruby":
                if ruby == nil {
                    ruby = version
                }
            case "npm", "pnpm", "yarn", "bun":
                if packageManagerVersions[tool] == nil {
                    packageManagerVersions[tool] = normalizedPackageManagerVersion(version)
                }
            default:
                continue
            }
        }

        return ToolVersionsMetadata(
            node: node,
            python: python,
            ruby: ruby,
            packageManagerVersions: packageManagerVersions
        )
    }

    private func tomlStringVersion(from rawValue: String) -> String? {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }

        if value.hasPrefix("[") {
            let remainder = String(value.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
            return tomlStringVersion(from: remainder)
        }

        if let quote = value.first, quote == "\"" || quote == "'" {
            let remainder = value.dropFirst()
            guard let endIndex = remainder.firstIndex(of: quote) else { return nil }
            let version = String(remainder[..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            return version.isEmpty ? nil : version
        }

        let token = value
            .split { character in
                character.isWhitespace || character == "," || character == "]" || character == "#"
            }
            .first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return token?.isEmpty == false ? token : nil
    }

    private func tomlSectionName(from line: String) -> String? {
        let withoutComment = line
            .split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard withoutComment.hasPrefix("["), withoutComment.hasSuffix("]") else { return nil }

        return withoutComment
            .dropFirst()
            .dropLast()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func declaredPackageManager(from rawPackageManager: String) -> DeclaredPackageManagerMetadata {
        let value = rawPackageManager.trimmingCharacters(in: .whitespacesAndNewlines)
        for packageManager in ["pnpm", "yarn", "bun", "npm"] {
            if value == packageManager {
                return DeclaredPackageManagerMetadata(
                    declaredPackageManager: DeclaredPackageManager(name: packageManager, version: nil),
                    versionWasUnsafe: false
                )
            }

            if value.hasPrefix("\(packageManager)@") {
                let version = normalizedPackageManagerVersion(
                    String(value.dropFirst(packageManager.count + 1))
                )
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard !version.isEmpty else {
                    return DeclaredPackageManagerMetadata(declaredPackageManager: nil, versionWasUnsafe: false)
                }

                guard isSafeVersionMetadataValue(version) else {
                    return DeclaredPackageManagerMetadata(
                        declaredPackageManager: DeclaredPackageManager(name: packageManager, version: nil),
                        versionWasUnsafe: true
                    )
                }

                return DeclaredPackageManagerMetadata(
                    declaredPackageManager: DeclaredPackageManager(name: packageManager, version: version),
                    versionWasUnsafe: false
                )
            }
        }

        return DeclaredPackageManagerMetadata(declaredPackageManager: nil, versionWasUnsafe: false)
    }

    private func normalizedPackageManagerVersion(_ rawVersion: String) -> String {
        rawVersion
            .split(separator: "+", maxSplits: 1, omittingEmptySubsequences: false)
            .first
            .map(String.init) ?? rawVersion
    }

    private func voltaMetadata(from rawValue: Any?) -> VoltaMetadata {
        guard let object = rawValue as? [String: Any] else { return .empty }
        var unsafeMetadataFields: [String] = []
        let node = safeVersionMetadataString(object["node"], fieldName: "package.json volta.node", unsafeMetadataFields: &unsafeMetadataFields)
        var packageManagerVersions: [String: String] = [:]

        for packageManager in ["npm", "pnpm", "yarn", "bun"] {
            if let version = safeVersionMetadataString(
                object[packageManager],
                fieldName: "package.json volta.\(packageManager)",
                unsafeMetadataFields: &unsafeMetadataFields
            ) {
                packageManagerVersions[packageManager] = normalizedPackageManagerVersion(version)
            }
        }

        return VoltaMetadata(
            node: node,
            packageManagerVersions: packageManagerVersions,
            unsafeMetadataFields: unsafeMetadataFields
        )
    }

    private func enginesMetadata(from rawValue: Any?) -> EnginesMetadata {
        guard let object = rawValue as? [String: Any] else { return .empty }
        var unsafeMetadataFields: [String] = []
        let node = safeVersionMetadataString(
            object["node"],
            fieldName: "package.json engines.node",
            unsafeMetadataFields: &unsafeMetadataFields
        )
        return EnginesMetadata(node: node, unsafeMetadataFields: unsafeMetadataFields)
    }

    private func safeVersionMetadataString(_ value: Any?, fieldName: String, unsafeMetadataFields: inout [String]) -> String? {
        guard let string = value as? String else { return nil }
        let normalized = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }
        guard isSafeVersionMetadataValue(normalized) else {
            unsafeMetadataFields.append(fieldName)
            return nil
        }
        return normalized
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
        guard !isSymbolicLink(url) else { return nil }
        let lastPath = url.lastPathComponent
        guard lastPath == ".nvmrc" || lastPath == ".node-version" || lastPath == ".python-version" || lastPath == ".ruby-version" else { return nil }
        guard fileSize(at: url) <= 4 * 1024 else { return nil }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        guard let line = content
            .split(whereSeparator: \.isNewline)
            .first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            return nil
        }

        guard isSafeDirectRuntimeHintValue(line) else { return nil }
        return line
    }

    private func isSafeDirectRuntimeHintValue(_ value: String) -> Bool {
        guard !value.contains(where: \.isWhitespace) else { return false }
        return isSafeVersionMetadataValue(value)
    }

    private func isSafeVersionMetadataValue(_ value: String) -> Bool {
        guard !value.isEmpty, value.count <= 80 else { return false }
        guard value.unicodeScalars.allSatisfy({ scalar in
            CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_+/<>~=^|*xX ")
                .contains(scalar)
        }) else {
            return false
        }

        let lowercased = value.lowercased()
        if lowercased == "node" || lowercased == "stable" || lowercased == "system" || lowercased == "lts/*" {
            return true
        }

        guard value.contains(where: \.isNumber) else { return false }

        let allowedWords: Set<String> = [
            "v", "x", "alpha", "beta", "rc", "pre", "dev", "next", "canary", "snapshot", "nightly", "lts"
        ]
        let words = lowercased.split { !$0.isLetter }.map(String.init)
        return words.allSatisfy { allowedWords.contains($0) }
    }

    private func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }

    private func isSymbolicLink(_ url: URL) -> Bool {
        (try? FileManager.default.destinationOfSymbolicLink(atPath: url.path)) != nil
    }

    private func hasSymbolicLinkAncestor(relativePath: String, projectURL: URL) -> Bool {
        firstSymbolicLinkAncestor(relativePath: relativePath, projectURL: projectURL) != nil
    }

    private func firstSymbolicLinkAncestor(relativePath: String, projectURL: URL) -> String? {
        let components = relativePath.split(separator: "/").map(String.init)
        guard components.count > 1 else { return nil }

        var currentURL = projectURL
        var relativeComponents: [String] = []
        for component in components.dropLast() {
            relativeComponents.append(component)
            currentURL.appendPathComponent(component)
            if isSymbolicLink(currentURL) {
                return relativeComponents.joined(separator: "/")
            }
        }

        return nil
    }
}

private struct DeclaredPackageManager {
    let name: String
    let version: String?
}

private struct PackageJSONMetadata {
    static let empty = PackageJSONMetadata(declaredPackageManager: nil, scripts: [], node: nil, packageManagerVersions: [:], unsafeMetadataFields: [])

    let declaredPackageManager: DeclaredPackageManager?
    let scripts: [String]
    let node: String?
    let packageManagerVersions: [String: String]
    let unsafeMetadataFields: [String]
}

private struct DeclaredPackageManagerMetadata {
    let declaredPackageManager: DeclaredPackageManager?
    let versionWasUnsafe: Bool
}

private struct ToolVersionsMetadata {
    static let empty = ToolVersionsMetadata(node: nil, python: nil, ruby: nil, packageManagerVersions: [:])

    let node: String?
    let python: String?
    let ruby: String?
    let packageManagerVersions: [String: String]

    var isEmpty: Bool {
        node == nil && python == nil && ruby == nil && packageManagerVersions.isEmpty
    }
}

private struct SourcedToolVersionsMetadata {
    static let empty = SourcedToolVersionsMetadata(metadata: .empty, source: nil)

    let metadata: ToolVersionsMetadata
    let source: String?
}

private struct PackageManagerVersionInfo {
    static let empty = PackageManagerVersionInfo(version: nil, source: nil)

    let version: String?
    let source: String?
}

private struct VoltaMetadata {
    static let empty = VoltaMetadata(node: nil, packageManagerVersions: [:], unsafeMetadataFields: [])

    let node: String?
    let packageManagerVersions: [String: String]
    let unsafeMetadataFields: [String]
}

private struct EnginesMetadata {
    static let empty = EnginesMetadata(node: nil, unsafeMetadataFields: [])

    let node: String?
    let unsafeMetadataFields: [String]
}
