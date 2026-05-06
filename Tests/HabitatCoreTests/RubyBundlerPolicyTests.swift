import Testing
import Foundation
@testable import HabitatCore

struct RubyBundlerPolicyTests {
    @Test
    func scanTreatsBundlerSignalsAsRubyProjectsAndGuardsMissingBundle() throws {
        for signal in ["Gemfile", "Gemfile.lock"] {
            let projectURL = try makeProject(files: [
                signal: "ruby dependency signal\n",
            ])

            let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "bundler", "Expected \(signal) to select Bundler commands")
            #expect(result.policy.preferredCommands.isEmpty)
            #expect(result.policy.askFirstCommands.contains("running Bundler commands before bundle is available"))
            #expect(result.policy.askFirstCommands.contains("bundle install"))
            #expect(result.warnings.contains("Project files prefer Bundler, but bundle was not found on PATH; ask before running Bundler commands."))
            #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(context.contains("Verify `bundle` before running Bundler commands."))
            #expect(context.contains("Ask before `running Bundler commands before bundle is available`."))
            #expect(context.contains("Ask before `bundle install`."))
            #expect(!context.contains("Prefer `bundle exec`."))
            #expect(!policy.contains("`bundle exec`"))
            #expect(policy.contains("`running Bundler commands before bundle is available`"))
        }
    }

    @Test
    func scanDoesNotAllowIncompleteBundlerCommandPrefix() throws {
        let projectURL = try makeProject(files: [
            "Gemfile": "source \"https://rubygems.org\"\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env bundle --version": .init(name: "/usr/bin/env", args: ["bundle", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Bundler version 2.5.10", stderr: ""),
            "/usr/bin/which -a bundle": .init(name: "/usr/bin/which", args: ["-a", "bundle"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/bundle", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "bundler")
        #expect(result.policy.preferredCommands.isEmpty)

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use Bundler (`bundle`) because project files point to it."))
        #expect(!context.contains("Prefer `bundle exec`."))
        #expect(!policy.contains("`bundle exec`"))
        #expect(policy.contains("`read-only project inspection, including rg <pattern>`"))
    }

    @Test
    func scanClassifiesBundlerDependencyMutationsAsAskFirst() throws {
        let projectURL = try makeProject(files: [
            "Gemfile": "source \"https://rubygems.org\"\n",
            "Gemfile.lock": "GEM\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env bundle --version": .init(name: "/usr/bin/env", args: ["bundle", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Bundler version 2.5.10", stderr: ""),
            "/usr/bin/which -a bundle": .init(name: "/usr/bin/which", args: ["-a", "bundle"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/bundle", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        for command in ["bundle install", "bundle add", "bundle update", "bundle lock", "bundle remove"] {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `bundle update`."))
        #expect(policy.contains("`bundle add`"))
        #expect(policy.contains("`bundle update`"))
        #expect(policy.contains("`bundle lock`"))
    }

    @Test
    func scanForbidsBundlerConfigValueReads() throws {
        let projectURL = try makeProject(files: [
            "Gemfile": "source \"https://rubygems.org\"\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        for command in ["bundle config", "bundle config list", "bundle config get", "bundle config set", "bundle config unset"] {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(policy.contains("`bundle config`"))
        #expect(policy.contains("`bundle config list`"))
        #expect(policy.contains("`bundle config get`"))
        #expect(policy.contains("`bundle config set`"))
        #expect(policy.contains("`bundle config unset`"))
    }

    @Test
    func scanAsksBeforeBundlerCommandsWhenBundleVersionCheckFails() throws {
        let projectURL = try makeProject(files: [
            "Gemfile": "source \"https://rubygems.org\"\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env bundle --version": .init(name: "/usr/bin/env", args: ["bundle", "--version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "bundle: failed to load command"),
            "/usr/bin/which -a bundle": .init(name: "/usr/bin/which", args: ["-a", "bundle"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/bundle", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "bundler")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Bundler commands before bundle version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running Bundler commands before bundle is available"))
        #expect(result.diagnostics.contains("bundle --version failed with exit code 1: bundle: failed to load command"))
        #expect(result.tools.versions.contains(where: { $0.name == "bundle" && !$0.available }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running Bundler commands before bundle version check succeeds`."))
        #expect(context.contains("bundle --version failed with exit code 1: bundle: failed to load command"))
        #expect(!context.contains("Prefer `bundle exec`."))
        #expect(policy.contains("`running Bundler commands before bundle version check succeeds`"))
        #expect(!policy.contains("`bundle exec`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanUsesRubyVersionHintsForBundlerInstallGuard() throws {
        let cases: [(file: String, content: String)] = [
            (".ruby-version", "3.3.0\n"),
            (".tool-versions", "ruby 3.3.0\n"),
        ]

        for testCase in cases {
            let projectURL = try makeProject(files: [
                "Gemfile": "source \"https://rubygems.org\"\n",
                testCase.file: testCase.content,
            ])

            let runner = FakeCommandRunner(results: [
                "/usr/bin/env ruby --version": .init(name: "/usr/bin/env", args: ["ruby", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "ruby 3.2.2", stderr: ""),
                "/usr/bin/env bundle --version": .init(name: "/usr/bin/env", args: ["bundle", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Bundler version 2.5.10", stderr: ""),
                "/usr/bin/which -a ruby": .init(name: "/usr/bin/which", args: ["-a", "ruby"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/ruby", stderr: ""),
                "/usr/bin/which -a bundle": .init(name: "/usr/bin/which", args: ["-a", "bundle"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/bundle", stderr: ""),
            ])

            let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

            #expect(result.project.packageManager == "bundler")
            #expect(result.project.detectedFiles.contains(testCase.file))
            #expect(result.project.runtimeHints.ruby == "3.3.0")
            #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Ruby to project version hints"))
            #expect(result.warnings.contains("Active Ruby is ruby 3.2.2, but project requests 3.3.0; ask before dependency installs (/opt/homebrew/bin/ruby)."))

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try ReportWriter().write(scanResult: result, outputURL: outputURL)
            let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
            let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
            let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

            #expect(scanResult.contains("\"ruby\" : \"3.3.0\""))
            #expect(context.contains("Ask before `dependency installs before matching active Ruby to project version hints`."))
            #expect(context.contains("Active Ruby is ruby 3.2.2, but project requests 3.3.0; ask before dependency installs"))
            #expect(policy.contains("`dependency installs before matching active Ruby to project version hints`"))
        }
    }
}
