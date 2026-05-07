import Testing
import Foundation
@testable import HabitatCore

struct HomebrewApplePolicyTests {
    @Test
    func scanGuardsHomebrewHostStateMutationCommands() throws {
        let projectURL = try makeProject(files: [
            "Brewfile": "brew \"swiftlint\"\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let askFirstCommands = [
            "brew tap",
            "brew tap-new",
        ]
        let forbiddenCommands = [
            "brew untap",
            "brew services start",
            "brew services stop",
            "brew services restart",
            "brew services run",
            "brew services cleanup",
        ]

        for command in askFirstCommands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }

        for command in forbiddenCommands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in askFirstCommands + forbiddenCommands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanTreatsBrewfileAsHomebrewProjectAndGuardsBundleMutation() throws {
        let projectURL = try makeProject(files: [
            "Brewfile": "brew \"swiftlint\"\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "homebrew")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Homebrew Bundle commands before brew is available"))
        #expect(result.policy.askFirstCommands.contains("brew bundle"))
        #expect(result.policy.askFirstCommands.contains("brew bundle install"))
        #expect(result.policy.askFirstCommands.contains("brew bundle cleanup"))
        #expect(result.policy.askFirstCommands.contains("brew bundle dump"))
        #expect(result.policy.askFirstCommands.contains("brew update"))
        #expect(result.policy.askFirstCommands.contains("brew cleanup"))
        #expect(result.policy.askFirstCommands.contains("brew autoremove"))
        #expect(result.warnings.contains("Project files include Brewfile, but brew was not found on PATH; ask before running Homebrew Bundle commands."))
        #expect(!result.warnings.contains("No primary package manager signal detected; prefer read-only inspection before mutation."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `brew` before running Homebrew Bundle commands."))
        #expect(context.contains("Ask before `running Homebrew Bundle commands before brew is available`."))
        #expect(context.contains("Ask before `brew bundle`."))
        #expect(context.contains("Project files include Brewfile, but brew was not found on PATH; ask before running Homebrew Bundle commands."))
        #expect(!context.contains("Prefer `brew bundle check`."))
        #expect(!policy.contains("`brew bundle check`"))
        #expect(policy.contains("`brew bundle install`"))
        #expect(policy.contains("`brew bundle cleanup`"))
        #expect(policy.contains("`brew bundle dump`"))
        #expect(policy.contains("`brew update`"))
        #expect(policy.contains("`brew cleanup`"))
        #expect(policy.contains("`brew autoremove`"))
    }

    @Test
    func scanAsksBeforeHomebrewBundleCommandsWhenBrewVersionCheckFails() throws {
        let projectURL = try makeProject(files: [
            "Brewfile": "brew \"swiftlint\"\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env brew --version": .init(name: "/usr/bin/env", args: ["brew", "--version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "brew: failed to load"),
            "/usr/bin/which -a brew": .init(name: "/usr/bin/which", args: ["-a", "brew"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/brew", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "homebrew")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Homebrew Bundle commands before brew version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running Homebrew Bundle commands before brew is available"))
        #expect(result.diagnostics.contains("brew --version failed with exit code 1: brew: failed to load"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running Homebrew Bundle commands before brew version check succeeds`."))
        #expect(context.contains("brew --version failed with exit code 1: brew: failed to load"))
        #expect(!context.contains("Prefer `brew bundle check`."))
        #expect(policy.contains("`running Homebrew Bundle commands before brew version check succeeds`"))
        #expect(!policy.contains("`brew bundle check`"))
        #expect(!policy.contains("`build commands for the selected project`"))
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
            #expect(result.policy.preferredCommands.isEmpty)
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

            #expect(context.contains("Verify `pod` before running CocoaPods commands."))
            #expect(context.contains("Ask before `running CocoaPods commands before pod is available`."))
            #expect(context.contains("Ask before `pod install`."))
            #expect(context.contains("Project files prefer CocoaPods, but pod was not found on PATH; ask before running CocoaPods commands."))
            #expect(!context.contains("Prefer `pod --version`."))
            #expect(!policy.contains("`pod --version`"))
            #expect(policy.contains("`pod install`"))
            #expect(policy.contains("`pod update`"))
            #expect(policy.contains("`pod repo update`"))
            #expect(policy.contains("`pod deintegrate`"))
        }
    }

    @Test
    func scanAsksBeforeCocoaPodsCommandsWhenPodVersionCheckFails() throws {
        let projectURL = try makeProject(files: [
            "Podfile": "platform :ios, '17.0'\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env pod --version": .init(name: "/usr/bin/env", args: ["pod", "--version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "pod: failed to load"),
            "/usr/bin/which -a pod": .init(name: "/usr/bin/which", args: ["-a", "pod"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pod", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "cocoapods")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running CocoaPods commands before pod version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running CocoaPods commands before pod is available"))
        #expect(result.diagnostics.contains("pod --version failed with exit code 1: pod: failed to load"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running CocoaPods commands before pod version check succeeds`."))
        #expect(context.contains("pod --version failed with exit code 1: pod: failed to load"))
        #expect(!context.contains("Prefer `pod --version`."))
        #expect(policy.contains("`running CocoaPods commands before pod version check succeeds`"))
        #expect(!policy.contains("`pod --version`"))
        #expect(!policy.contains("`test commands for the selected project`"))
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
            #expect(result.policy.preferredCommands.isEmpty)
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

            #expect(context.contains("Verify `carthage` before running Carthage commands."))
            #expect(context.contains("Ask before `running Carthage commands before carthage is available`."))
            #expect(context.contains("Ask before `carthage bootstrap`."))
            #expect(context.contains("Project files prefer Carthage, but carthage was not found on PATH; ask before running Carthage commands."))
            #expect(!context.contains("Prefer `carthage version`."))
            #expect(!policy.contains("`carthage version`"))
            #expect(policy.contains("`carthage bootstrap`"))
            #expect(policy.contains("`carthage update`"))
            #expect(policy.contains("`carthage checkout`"))
            #expect(policy.contains("`carthage build`"))
        }
    }

    @Test
    func scanAsksBeforeCarthageCommandsWhenCarthageVersionCheckFails() throws {
        let projectURL = try makeProject(files: [
            "Cartfile": "github \"Alamofire/Alamofire\"\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env carthage version": .init(name: "/usr/bin/env", args: ["carthage", "version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "carthage: failed to load"),
            "/usr/bin/which -a carthage": .init(name: "/usr/bin/which", args: ["-a", "carthage"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/carthage", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "carthage")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Carthage commands before carthage version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running Carthage commands before carthage is available"))
        #expect(result.diagnostics.contains("carthage version failed with exit code 1: carthage: failed to load"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running Carthage commands before carthage version check succeeds`."))
        #expect(context.contains("carthage version failed with exit code 1: carthage: failed to load"))
        #expect(!context.contains("Prefer `carthage version`."))
        #expect(policy.contains("`running Carthage commands before carthage version check succeeds`"))
        #expect(!policy.contains("`carthage version`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }
}
