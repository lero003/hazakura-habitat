import Testing
import Foundation
@testable import HabitatCore

struct FakeCommandRunner: CommandRunning {
    let results: [String: CommandInfo]

    func run(executable: String, arguments: [String], timeout: TimeInterval) -> CommandInfo {
        let key = ([executable] + arguments).joined(separator: " ")
        return results[key] ?? CommandInfo(
            name: executable,
            args: arguments,
            exitCode: nil,
            durationMs: 0,
            timedOut: false,
            available: false,
            stdout: "",
            stderr: "missing"
        )
    }
}

struct HabitatCoreTests {
    @Test
    func scanPrefersPnpmWhenLockfileExists() throws {
        let projectURL = try makeProject(files: [
            "pnpm-lock.yaml": "lockfile",
            "package.json": "{}",
            ".nvmrc": "v20\n",
            ".env.example": "EXAMPLE=1\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.runtimeHints.node == "v20")
        #expect(result.policy.preferredCommands.contains("pnpm run"))
        #expect(result.warnings.contains(where: { $0.contains("do not read real .env values") }))
    }

    @Test
    func scanWarnsWhenActiveNodeDiffersFromNvmrc() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "pnpm-lock.yaml": "lockfile",
            ".nvmrc": "v20\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v25.9.0", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.warnings.contains("Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node)."))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
    }

    @Test
    func scanUsesNodeVersionFileForRuntimeInstallGuard() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
            ".node-version": "24.0.0\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "v22.15.0", stderr: ""),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".node-version"))
        #expect(result.project.runtimeHints.node == "24.0.0")
        #expect(result.warnings.contains("Active Node is v22.15.0, but project requests 24.0.0; ask before dependency installs (/opt/homebrew/bin/node)."))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
    }

    @Test
    func scanWarnsBeforeSubstitutingMissingPreferredPackageManager() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "pnpm-lock.yaml": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.policy.askFirstCommands.contains("substituting another package manager for pnpm"))
        #expect(result.warnings.contains("Project files prefer pnpm, but pnpm was not found on PATH; ask before substituting another package manager."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        #expect(context.contains("Ask before `substituting another package manager for pnpm`."))
    }

    @Test
    func scanAsksBeforeInstallsWhenMultipleJavaScriptLockfilesExist() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "npm lockfile",
            "pnpm-lock.yaml": "pnpm lockfile",
            "yarn.lock": "yarn lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.policy.askFirstCommands.contains("dependency installs when multiple JavaScript lockfiles exist"))
        #expect(result.warnings.contains("Multiple JavaScript lockfiles detected (package-lock.json, pnpm-lock.yaml, yarn.lock); ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `dependency installs when multiple JavaScript lockfiles exist`."))
        #expect(context.contains("Multiple JavaScript lockfiles detected (package-lock.json, pnpm-lock.yaml, yarn.lock); ask before dependency installs."))
        #expect(policy.contains("`dependency installs when multiple JavaScript lockfiles exist`"))
    }

    @Test
    func scanAsksBeforeLockfileMutation() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.policy.askFirstCommands.contains("modifying lockfiles"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`modifying lockfiles`"))
    }

    @Test
    func scanTreatsPackageJsonOnlyAsNpmProjectAndGuardsMissingNpm() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.project.packageScripts.isEmpty)
        #expect(result.policy.preferredCommands == ["npm run"])
        #expect(result.policy.askFirstCommands.contains("substituting another package manager for npm"))
        #expect(result.warnings.contains("Project files prefer npm, but npm was not found on PATH; ask before substituting another package manager."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `npm` because project files point to it."))
        #expect(context.contains("Prefer `npm run`."))
        #expect(context.contains("Ask before `substituting another package manager for npm`."))
        #expect(policy.contains("`npm run`"))
        #expect(policy.contains("`substituting another package manager for npm`"))
    }

    @Test
    func scanUsesPackageJsonScriptNamesForJavaScriptPreferredCommands() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "scripts": {
                "build": "vite build",
                "deploy": "secret deploy target",
                "test": "vitest run"
              }
            }
            """,
            "package-lock.json": "lockfile",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.project.packageScripts == ["build", "deploy", "test"])
        #expect(result.policy.preferredCommands == ["npm run test", "npm run build"])

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Prefer `npm run test`."))
        #expect(context.contains("Prefer `npm run build`."))
        #expect(!context.contains("secret deploy target"))
        #expect(!context.contains("npm run deploy"))
    }

    @Test
    func scanUsesPackageManagerFieldWhenNoJavaScriptLockfileExists() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "pnpm@9.15.4",
              "scripts": {
                "build": "vite build",
                "test": "vitest run"
              }
            }
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "9.15.4", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.project.packageScripts == ["build", "test"])
        #expect(result.policy.preferredCommands == ["pnpm run test", "pnpm run build"])
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))
        #expect(!result.policy.askFirstCommands.contains("substituting another package manager for pnpm"))
        #expect(!result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `pnpm@9.15.4` because `package.json` packageManager points to it."))
        #expect(context.contains("Prefer `pnpm run test`."))
        #expect(policy.contains("`pnpm run build`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenPackageManagerVersionDiffers() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "pnpm@9.15.4"
            }
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "10.0.0", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))
        #expect(result.warnings.contains("Project requests pnpm 9.15.4 via package.json; active pnpm is 10.0.0; ask before dependency installs."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `pnpm@9.15.4` because `package.json` packageManager points to it."))
        #expect(context.contains("Ask before `dependency installs before matching pnpm to packageManager version`."))
        #expect(policy.contains("`dependency installs before matching pnpm to packageManager version`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenPackageManagerVersionCannotBeVerified() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "yarn@4.8.1"
            }
            """,
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "yarn")
        #expect(result.project.packageManagerVersion == "4.8.1")
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching yarn to packageManager version"))
        #expect(result.warnings.contains("Project requests yarn 4.8.1 via package.json; verify active yarn before dependency installs."))
    }

    @Test
    func scanAsksBeforeInstallsWhenPackageManagerVersionCommandFails() throws {
        let projectURL = try makeProject(files: [
            "package.json": """
            {
              "name": "demo",
              "packageManager": "pnpm@9.15.4"
            }
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a pnpm": .init(name: "/usr/bin/which", args: ["-a", "pnpm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pnpm", stderr: ""),
            "/usr/bin/env pnpm --version": .init(name: "/usr/bin/env", args: ["pnpm", "--version"], exitCode: 127, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "env: pnpm: No such file or directory"),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "pnpm")
        #expect(result.project.packageManagerVersion == "9.15.4")
        #expect(result.tools.versions.contains(where: { $0.name == "pnpm" && !$0.available && $0.version == nil }))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching pnpm to packageManager version"))
        #expect(result.warnings.contains("Project requests pnpm 9.15.4 via package.json; verify active pnpm before dependency installs."))
        #expect(result.diagnostics.contains("pnpm --version failed with exit code 127: env: pnpm: No such file or directory"))
    }

    @Test
    func scanDoesNotReadOrEmitSecretFileValues() throws {
        let secretValue = "sk-habitat-test-secret-123"
        let privateKeyMarker = "-----BEGIN OPENSSH PRIVATE KEY-----"
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            ".nvmrc": "v20\n",
            ".env": "OPENAI_API_KEY=\(secretValue)\n",
            ".env.local": "LOCAL_TOKEN=\(secretValue)\n",
            ".env.example": "OPENAI_API_KEY=\n",
            "id_rsa": "\(privateKeyMarker)\n\(secretValue)\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".env"))
        #expect(result.project.detectedFiles.contains(".env.local"))
        #expect(result.project.detectedFiles.contains(".env.example"))
        #expect(result.project.runtimeHints.node == "v20")
        #expect(result.warnings.contains("Environment file exists; do not read .env values."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("OPENAI_API_KEY"))
            #expect(!artifact.contains("LOCAL_TOKEN"))
            #expect(!artifact.contains(privateKeyMarker))
        }
    }

    @Test
    func scanWarnsForCommonSecretEnvironmentFiles() throws {
        for envFile in [".env.local", ".env.development", ".env.development.local", ".env.test", ".env.test.local", ".env.production", ".env.production.local"] {
            let projectURL = try makeProject(files: [
                envFile: "SECRET=value\n",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

            #expect(result.project.detectedFiles.contains(envFile), "Expected \(envFile) to be detected")
            #expect(result.warnings.contains("Environment file exists; do not read .env values."), "Expected \(envFile) to trigger secret env guidance")
        }
    }

    @Test
    func scanPrefersProjectVenvForPythonCommands() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            ".python-version": "3.12\n",
        ])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent(".venv"), withIntermediateDirectories: true)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".venv"))
        #expect(result.project.packageManager == "python")
        #expect(result.project.runtimeHints.python == "3.12")
        #expect(result.policy.preferredCommands.first == ".venv/bin/python -m pytest")
        #expect(result.warnings.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Prefer `.venv/bin/python -m pytest`."))
        #expect(context.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))
    }

    @Test
    func scanTreatsSecondaryPythonSignalsAsPythonProjects() throws {
        for signal in ["requirements-dev.txt", "Pipfile", "Pipfile.lock"] {
            let projectURL = try makeProject(files: [
                signal: "test dependency signal\n",
            ])

            let runner = FakeCommandRunner(results: [
                "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
            ])

            let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "python", "Expected \(signal) to select Python commands")
            #expect(result.policy.preferredCommands == ["python3 -m pytest"])

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

            #expect(context.contains("Use `python` because project files point to it."))
            #expect(context.contains("Prefer `python3 -m pytest`."))
        }
    }

    @Test
    func scanTreatsBundlerSignalsAsRubyProjectsAndGuardsMissingBundle() throws {
        for signal in ["Gemfile", "Gemfile.lock"] {
            let projectURL = try makeProject(files: [
                signal: "ruby dependency signal\n",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "bundler", "Expected \(signal) to select Bundler commands")
            #expect(result.policy.preferredCommands == ["bundle exec"])
            #expect(result.policy.askFirstCommands.contains("running Bundler commands before bundle is available"))
            #expect(result.policy.askFirstCommands.contains("bundle install"))
            #expect(result.warnings.contains("Project files prefer Bundler, but bundle was not found on PATH; ask before running Bundler commands."))
            #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(context.contains("Use `bundler` because project files point to it."))
            #expect(context.contains("Prefer `bundle exec`."))
            #expect(context.contains("Ask before `running Bundler commands before bundle is available`."))
            #expect(context.contains("Ask before `bundle install`."))
            #expect(policy.contains("`bundle exec`"))
            #expect(policy.contains("`running Bundler commands before bundle is available`"))
        }
    }

    @Test
    func scanTreatsGoModAsGoProjectAndGuardsMissingGo() throws {
        let projectURL = try makeProject(files: [
            "go.mod": "module example.com/demo\n\ngo 1.22\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "go")
        #expect(result.policy.preferredCommands == ["go test ./...", "go build ./..."])
        #expect(result.policy.askFirstCommands.contains("running Go commands before go is available"))
        #expect(result.policy.askFirstCommands.contains("go get"))
        #expect(result.warnings.contains("Project files prefer Go, but go was not found on PATH; ask before running Go commands."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `go` because project files point to it."))
        #expect(context.contains("Prefer `go test ./...`."))
        #expect(context.contains("Ask before `running Go commands before go is available`."))
        #expect(context.contains("Ask before `go mod tidy`."))
        #expect(policy.contains("`go test ./...`"))
        #expect(policy.contains("`go get`"))
    }

    @Test
    func scanTreatsCargoTomlAsCargoProjectAndGuardsMissingCargo() throws {
        let projectURL = try makeProject(files: [
            "Cargo.toml": """
            [package]
            name = "demo"
            version = "0.1.0"
            edition = "2021"
            """,
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "cargo")
        #expect(result.policy.preferredCommands == ["cargo test", "cargo build"])
        #expect(result.policy.askFirstCommands.contains("running Cargo commands before cargo is available"))
        #expect(result.policy.askFirstCommands.contains("cargo add"))
        #expect(result.policy.askFirstCommands.contains("cargo update"))
        #expect(result.warnings.contains("Project files prefer Cargo, but cargo was not found on PATH; ask before running Cargo commands."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `cargo` because project files point to it."))
        #expect(context.contains("Prefer `cargo test`."))
        #expect(context.contains("Ask before `running Cargo commands before cargo is available`."))
        #expect(context.contains("Ask before `cargo update`."))
        #expect(policy.contains("`cargo test`"))
        #expect(policy.contains("`cargo add`"))
    }

    @Test
    func scanTreatsBrewfileAsHomebrewProjectAndGuardsBundleMutation() throws {
        let projectURL = try makeProject(files: [
            "Brewfile": "brew \"swiftlint\"\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "homebrew")
        #expect(result.policy.preferredCommands == ["brew bundle check"])
        #expect(result.policy.askFirstCommands.contains("running Homebrew Bundle commands before brew is available"))
        #expect(result.policy.askFirstCommands.contains("brew bundle"))
        #expect(result.policy.askFirstCommands.contains("brew bundle install"))
        #expect(result.policy.askFirstCommands.contains("brew bundle cleanup"))
        #expect(result.policy.askFirstCommands.contains("brew bundle dump"))
        #expect(result.warnings.contains("Project files include Brewfile, but brew was not found on PATH; ask before running Homebrew Bundle commands."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `homebrew` because project files point to it."))
        #expect(context.contains("Prefer `brew bundle check`."))
        #expect(context.contains("Ask before `running Homebrew Bundle commands before brew is available`."))
        #expect(context.contains("Ask before `brew bundle`."))
        #expect(context.contains("Project files include Brewfile, but brew was not found on PATH; ask before running Homebrew Bundle commands."))
        #expect(policy.contains("`brew bundle check`"))
        #expect(policy.contains("`brew bundle install`"))
        #expect(policy.contains("`brew bundle cleanup`"))
        #expect(policy.contains("`brew bundle dump`"))
    }

    @Test
    func scanTreatsPodfileAsCocoaPodsProjectAndGuardsPodMutation() throws {
        for signal in ["Podfile", "Podfile.lock"] {
            let projectURL = try makeProject(files: [
                signal: "cocoapods dependency signal\n",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "cocoapods", "Expected \(signal) to select CocoaPods guidance")
            #expect(result.project.detectedFiles.contains(signal))
            #expect(result.policy.preferredCommands == ["pod --version"])
            #expect(result.policy.askFirstCommands.contains("running CocoaPods commands before pod is available"))
            #expect(result.policy.askFirstCommands.contains("pod install"))
            #expect(result.policy.askFirstCommands.contains("pod update"))
            #expect(result.policy.askFirstCommands.contains("pod repo update"))
            #expect(result.policy.askFirstCommands.contains("pod deintegrate"))
            #expect(result.warnings.contains("Project files prefer CocoaPods, but pod was not found on PATH; ask before running CocoaPods commands."))
            #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(context.contains("Use `cocoapods` because project files point to it."))
            #expect(context.contains("Prefer `pod --version`."))
            #expect(context.contains("Ask before `running CocoaPods commands before pod is available`."))
            #expect(context.contains("Ask before `pod install`."))
            #expect(context.contains("Project files prefer CocoaPods, but pod was not found on PATH; ask before running CocoaPods commands."))
            #expect(policy.contains("`pod --version`"))
            #expect(policy.contains("`pod install`"))
            #expect(policy.contains("`pod update`"))
            #expect(policy.contains("`pod repo update`"))
            #expect(policy.contains("`pod deintegrate`"))
        }
    }

    @Test
    func scanTreatsCartfileAsCarthageProjectAndGuardsCarthageMutation() throws {
        for signal in ["Cartfile", "Cartfile.resolved"] {
            let projectURL = try makeProject(files: [
                signal: "github \"Alamofire/Alamofire\"\n",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "carthage", "Expected \(signal) to select Carthage guidance")
            #expect(result.project.detectedFiles.contains(signal))
            #expect(result.policy.preferredCommands == ["carthage version"])
            #expect(result.policy.askFirstCommands.contains("running Carthage commands before carthage is available"))
            #expect(result.policy.askFirstCommands.contains("carthage bootstrap"))
            #expect(result.policy.askFirstCommands.contains("carthage update"))
            #expect(result.policy.askFirstCommands.contains("carthage checkout"))
            #expect(result.policy.askFirstCommands.contains("carthage build"))
            #expect(result.warnings.contains("Project files prefer Carthage, but carthage was not found on PATH; ask before running Carthage commands."))
            #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(context.contains("Use `carthage` because project files point to it."))
            #expect(context.contains("Prefer `carthage version`."))
            #expect(context.contains("Ask before `running Carthage commands before carthage is available`."))
            #expect(context.contains("Ask before `carthage bootstrap`."))
            #expect(context.contains("Project files prefer Carthage, but carthage was not found on PATH; ask before running Carthage commands."))
            #expect(policy.contains("`carthage version`"))
            #expect(policy.contains("`carthage bootstrap`"))
            #expect(policy.contains("`carthage update`"))
            #expect(policy.contains("`carthage checkout`"))
            #expect(policy.contains("`carthage build`"))
        }
    }

    @Test
    func scanGuardsUvProjectsWhenUvIsMissing() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            "uv.lock": "version = 1\n",
            ".python-version": "3.12\n",
        ])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent(".venv"), withIntermediateDirectories: true)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.12.4", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
            "/usr/bin/which -a pip3": .init(name: "/usr/bin/which", args: ["-a", "pip3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pip3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "uv")
        #expect(result.project.detectedFiles.contains("uv.lock"))
        #expect(result.policy.preferredCommands == ["uv run", ".venv/bin/python -m pytest"])
        #expect(result.policy.askFirstCommands.contains("substituting another package manager for uv"))
        #expect(result.warnings.contains("Project files prefer uv, but uv was not found on PATH; ask before substituting another package manager."))
        #expect(result.warnings.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `uv` because project files point to it."))
        #expect(context.contains("Prefer `uv run`."))
        #expect(context.contains("Ask before `substituting another package manager for uv`."))
        #expect(policy.contains("`uv run`"))
        #expect(policy.contains("`substituting another package manager for uv`"))
    }

    @Test
    func scanWarnsWhenActivePythonDiffersFromPythonVersion() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            ".python-version": "3.12\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.11.9", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.project.runtimeHints.python == "3.12")
        #expect(result.warnings.contains("Active Python is Python 3.11.9, but project requests 3.12; ask before dependency installs (/opt/homebrew/bin/python3)."))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Python to project version hints"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`dependency installs before matching active Python to project version hints`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenNodeVersionCommandFails() throws {
        let projectURL = try makeProject(files: [
            "package.json": "{}",
            "package-lock.json": "lockfile",
            ".nvmrc": "v20\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env node --version": .init(name: "/usr/bin/env", args: ["node", "--version"], exitCode: 127, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "env: node: No such file or directory"),
            "/usr/bin/which -a node": .init(name: "/usr/bin/which", args: ["-a", "node"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/node", stderr: ""),
            "/usr/bin/which -a npm": .init(name: "/usr/bin/which", args: ["-a", "npm"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/npm", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "npm")
        #expect(result.tools.versions.contains(where: { $0.name == "node" && !$0.available && $0.version == nil }))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Node to project version hints"))
        #expect(result.warnings.contains("Project requests Node v20; verify active node before installs (/opt/homebrew/bin/node)."))
        #expect(result.diagnostics.contains("node --version failed with exit code 127: env: node: No such file or directory"))
    }

    @Test
    func reportWriterCreatesAllArtifacts() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["swift test"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            #expect(FileManager.default.fileExists(atPath: outputURL.appendingPathComponent(name).path))
        }
    }

    @Test
    func agentContextIncludesRuntimeMismatchWarnings() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: [".nvmrc", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: "v20", python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["pnpm"], askFirstCommands: ["pnpm install"], forbiddenCommands: ["sudo"]),
            warnings: ["Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node)."],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Active Node is v25.9.0, but project requests v20; ask before dependency installs"))
    }

    @Test
    func commandPolicyIncludesRuntimeMismatchInstallGuard() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: [".nvmrc", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: "v20", python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["pnpm"],
                askFirstCommands: ["dependency installs before matching active Node to project version hints", "pnpm install"],
                forbiddenCommands: ["sudo"]
            ),
            warnings: ["Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node)."],
            diagnostics: []
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`dependency installs before matching active Node to project version hints`"))
    }

    @Test
    func agentContextMarkdownSnapshotStaysActionable() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = markdownSnapshotScanResult()

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context == """
        # Agent Context

        ## Freshness
        - Scanned at: 2026-04-25T00:00:00Z
        - Project: /tmp/project

        ## Use
        - Use `pnpm` because project files point to it.
        - Prefer `pnpm`.
        - Prefer `pnpm test`.

        ## Avoid
        - Do not run `sudo`.
        - Do not run `brew upgrade`.

        ## Ask First
        - Ask before `substituting another package manager for pnpm`.
        - Ask before `dependency installs before matching active Node to project version hints`.
        - Ask before `pnpm install`.
        - Ask before `modifying lockfiles`.

        ## Mismatches
        - Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node).
        - Project files prefer pnpm, but pnpm was not found on PATH; ask before substituting another package manager.

        ## Notes
        - node --version unavailable: missing
        """)
    }

    @Test
    func commandPolicyMarkdownSnapshotKeepsInstallGuardsVisible() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = markdownSnapshotScanResult()

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy == """
        # Command Policy

        ## Allowed
        - `pnpm`
        - `pnpm test`
        - `read-only project inspection`
        - `test commands for the selected project`
        - `build commands for the selected project`

        ## Ask First
        - `substituting another package manager for pnpm`
        - `dependency installs before matching active Node to project version hints`
        - `pnpm install`
        - `modifying lockfiles`

        ## Forbidden
        - `sudo`
        - `brew upgrade`

        ## If Dependency Installation Seems Necessary
        - Re-check lockfiles and version hints first.
        - Prefer the project-specific package manager from `agent_context.md`.
        - Ask before any install, upgrade, uninstall, or global mutation.
        """)
    }

    @Test
    func agentContextOmitsUnrelatedCommandDiagnostics() throws {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let result = ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: ["Package.swift"], packageManager: "swiftpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: nil, python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(preferredCommands: ["swift test"], askFirstCommands: [], forbiddenCommands: ["sudo"]),
            warnings: [],
            diagnostics: [
                "go version failed with exit code 127: env: go: No such file or directory",
                "swift --version failed with exit code 1: swift unavailable"
            ]
        )

        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        #expect(!context.contains("go version failed"))
        #expect(context.contains("swift --version failed with exit code 1"))
        #expect(report.contains("go version failed with exit code 127"))
    }

    @Test
    func scanKeepsGoingWhenCommandsAreMissing() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.commands.allSatisfy { !$0.available })
        #expect(result.diagnostics.count == result.commands.count)
    }

    @Test
    func scanGuardsSwiftPMCommandsWhenSwiftIsMissing() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift package"
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "swiftpm")
        #expect(result.policy.preferredCommands == ["swift test", "swift build"])
        #expect(result.policy.askFirstCommands.contains("running SwiftPM commands before swift is available"))
        #expect(result.policy.askFirstCommands.contains("swift package update"))
        #expect(result.policy.askFirstCommands.contains("swift package resolve"))
        #expect(result.warnings.contains("Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running SwiftPM commands before swift is available`."))
        #expect(context.contains("Ask before `swift package update`."))
        #expect(policy.contains("`swift package update`"))
        #expect(policy.contains("`swift package resolve`"))
        #expect(context.contains("Project files prefer SwiftPM, but swift was not found on PATH; ask before running SwiftPM commands."))
        #expect(policy.contains("`running SwiftPM commands before swift is available`"))
    }

    private func makeProject(files: [String: String]) throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

        for (path, contents) in files {
            let fileURL = root.appendingPathComponent(path)
            try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        }

        return root
    }

    private func markdownSnapshotScanResult() -> ScanResult {
        ScanResult(
            schemaVersion: "0.1",
            scannedAt: "2026-04-25T00:00:00Z",
            projectPath: "/tmp/project",
            system: .init(operatingSystemVersion: "macOS", architecture: "arm64", shell: "/bin/zsh", path: ["/usr/bin"]),
            commands: [],
            project: .init(detectedFiles: [".nvmrc", "package.json", "pnpm-lock.yaml"], packageManager: "pnpm", packageManagerVersion: nil, packageScripts: [], runtimeHints: .init(node: "v20", python: nil)),
            tools: .init(resolvedPaths: [], versions: []),
            policy: .init(
                preferredCommands: ["pnpm", "pnpm test"],
                askFirstCommands: [
                    "substituting another package manager for pnpm",
                    "dependency installs before matching active Node to project version hints",
                    "pnpm install",
                    "modifying lockfiles"
                ],
                forbiddenCommands: ["sudo", "brew upgrade"]
            ),
            warnings: [
                "Active Node is v25.9.0, but project requests v20; ask before dependency installs (/opt/homebrew/bin/node).",
                "Project files prefer pnpm, but pnpm was not found on PATH; ask before substituting another package manager."
            ],
            diagnostics: ["node --version unavailable: missing"]
        )
    }
}
