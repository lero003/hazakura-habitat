import Testing
import Foundation
@testable import HabitatCore

struct PackageAuthConfigPolicyTests {
    @Test
    func scanDetectsPnpmrcWithoutReadingTokenValues() throws {
        let secretValue = "hh_pnpm_token_secret_value"
        let projectURL = try makeProject(files: [
            ".pnpmrc": "//registry.npmjs.org/:_authToken=\(secretValue)\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".pnpmrc"))
        #expect(result.warnings.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(result.policy.forbiddenCommands.contains("read package manager auth config values"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("_authToken"))
        }

        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(scanResult.contains(".pnpmrc"))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive package manager auth config files."))
        #expect(context.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
    }

    @Test
    func scanDetectsPythonPackageAuthConfigWithoutReadingValues() throws {
        let secretValue = "hh_python_package_auth_secret_value"
        let projectURL = try makeProject(files: [
            ".pypirc": """
            [pypi]
            username = __token__
            password = \(secretValue)
            """,
            "pip.conf": """
            [global]
            index-url = https://__token__:\(secretValue)@pypi.example/simple
            """,
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".pypirc"))
        #expect(result.project.detectedFiles.contains("pip.conf"))
        #expect(result.warnings.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(result.warnings.contains("Package manager auth config files detected (.pypirc, pip.conf); do not read credential values."))
        #expect(result.policy.forbiddenCommands.contains("read package manager auth config values"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("pypi.example"))
            #expect(!artifact.contains("index-url"))
            #expect(!artifact.contains("password ="))
        }

        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains(".pypirc"))
        #expect(scanResult.contains("pip.conf"))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive package manager auth config files."))
        #expect(context.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(context.contains("Package manager auth config files detected (.pypirc, pip.conf); do not read credential values."))
        #expect(policy.contains("`read package manager auth config values`"))
    }

    @Test
    func scanDetectsRubyPackageAuthConfigWithoutReadingValues() throws {
        let secretValue = "hh_ruby_package_auth_secret_value"
        let projectURL = try makeProject(files: [
            "Gemfile": "source \"https://rubygems.org\"\n",
        ])
        let gemCredentialsURL = projectURL.appendingPathComponent(".gem/credentials")
        let bundleConfigURL = projectURL.appendingPathComponent(".bundle/config")
        try FileManager.default.createDirectory(at: gemCredentialsURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: bundleConfigURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try ":rubygems_api_key: \(secretValue)\n".write(to: gemCredentialsURL, atomically: true, encoding: .utf8)
        try "BUNDLE_RUBYGEMS__PKG__EXAMPLE__COM: \(secretValue)\n".write(to: bundleConfigURL, atomically: true, encoding: .utf8)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".gem/credentials"))
        #expect(result.project.detectedFiles.contains(".bundle/config"))
        #expect(result.warnings.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(result.policy.forbiddenCommands.contains("read package manager auth config values"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("rubygems_api_key"))
            #expect(!artifact.contains("BUNDLE_RUBYGEMS"))
            #expect(!artifact.contains("PKG__EXAMPLE__COM"))
        }

        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains(".gem/credentials"))
        #expect(scanResult.contains(".bundle/config"))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive package manager auth config files."))
        #expect(context.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(policy.contains("`read package manager auth config values`"))
    }

    @Test
    func scanDetectsCargoPackageAuthConfigWithoutReadingValues() throws {
        let secretValue = "hh_cargo_package_auth_secret_value"
        let projectURL = try makeProject(files: [
            "Cargo.toml": "[package]\nname = \"demo\"\nversion = \"0.1.0\"\n",
        ])
        let cargoCredentialsTomlURL = projectURL.appendingPathComponent(".cargo/credentials.toml")
        let cargoCredentialsURL = projectURL.appendingPathComponent(".cargo/credentials")
        try FileManager.default.createDirectory(at: cargoCredentialsTomlURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "[registries.private]\ntoken = \"\(secretValue)\"\n".write(to: cargoCredentialsTomlURL, atomically: true, encoding: .utf8)
        try "[registry]\ntoken = \"\(secretValue)\"\n".write(to: cargoCredentialsURL, atomically: true, encoding: .utf8)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".cargo/credentials.toml"))
        #expect(result.project.detectedFiles.contains(".cargo/credentials"))
        #expect(result.warnings.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(result.policy.forbiddenCommands.contains("read package manager auth config values"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("registries.private"))
            #expect(!artifact.contains("[registry]"))
        }

        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains(".cargo/credentials.toml"))
        #expect(scanResult.contains(".cargo/credentials"))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive package manager auth config files."))
        #expect(context.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(policy.contains("`read package manager auth config values`"))
    }

    @Test
    func scanDetectsComposerPackageAuthConfigWithoutReadingValues() throws {
        let secretValue = "hh_composer_package_auth_secret_value"
        let projectURL = try makeProject(files: [
            "auth.json": """
            {"github-oauth": {"github.com": "\(secretValue)"}}
            """,
        ])
        let composerAuthURL = projectURL.appendingPathComponent(".composer/auth.json")
        try FileManager.default.createDirectory(at: composerAuthURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try """
        {"http-basic": {"repo.example": {"username": "token", "password": "\(secretValue)"}}}
        """.write(to: composerAuthURL, atomically: true, encoding: .utf8)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains("auth.json"))
        #expect(result.project.detectedFiles.contains(".composer/auth.json"))
        #expect(result.warnings.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(result.policy.forbiddenCommands.contains("read package manager auth config values"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("github-oauth"))
            #expect(!artifact.contains("http-basic"))
            #expect(!artifact.contains("repo.example"))
            #expect(!artifact.contains("\"password\""))
        }

        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(scanResult.contains("auth.json"))
        #expect(scanResult.contains(".composer/auth.json"))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive package manager auth config files."))
        #expect(context.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(policy.contains("`read package manager auth config values`"))
    }
}
