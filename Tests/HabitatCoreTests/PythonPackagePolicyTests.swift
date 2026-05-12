import Testing
import Foundation
@testable import HabitatCore

struct PythonPackagePolicyTests {
    @Test
    func scanPrefersProjectVenvForPythonCommands() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            ".python-version": "3.12\n",
        ])
        try makeExecutableProjectVenvPython(projectURL)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".venv"))
        #expect(result.project.detectedFiles.contains(".venv/bin/python"))
        #expect(result.project.packageManager == "python")
        #expect(result.project.runtimeHints.python == "3.12")
        #expect(result.policy.preferredCommands.first == ".venv/bin/python -m pytest")
        #expect(result.warnings.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Prefer `.venv/bin/python -m pytest`."))
        #expect(context.contains("Warning: Project .venv exists; use .venv/bin/python for Python commands before system python3."))
        #expect(!context.contains("Mismatch: Project .venv exists; use .venv/bin/python for Python commands before system python3."))
    }

    @Test
    func scanAllowsProjectVenvWhenPython3IsMissing() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
        ])
        try makeExecutableProjectVenvPython(projectURL)

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.project.detectedFiles.contains(".venv/bin/python"))
        #expect(result.policy.preferredCommands == [".venv/bin/python -m pytest", ".venv/bin/python"])
        #expect(!result.policy.askFirstCommands.contains("running Python commands before python3 is available"))
        #expect(!result.warnings.contains("Project files prefer Python, but python3 was not found on PATH; ask before running Python commands."))
        #expect(result.warnings.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Prefer `.venv/bin/python -m pytest`."))
        #expect(!context.contains("Ask before `running Python commands before python3 is available`."))
        #expect(!context.contains("Project files prefer Python, but python3 was not found on PATH; ask before running Python commands."))
        #expect(policy.contains("`.venv/bin/python -m pytest`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`running Python commands before python3 is available`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanDoesNotTreatVenvPythonSymlinkAsProjectMetadataSymlink() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
        ])
        let python3URL = projectURL.appendingPathComponent(".venv/bin/python3")
        try writeExecutableScript(python3URL, contents: "#!/bin/sh\n")
        try FileManager.default.createSymbolicLink(
            atPath: projectURL.appendingPathComponent(".venv/bin/python").path,
            withDestinationPath: "python3"
        )

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".venv/bin/python"))
        #expect(!result.project.symlinkedFiles.contains(".venv/bin/python"))
        #expect(result.policy.preferredCommands == [".venv/bin/python -m pytest", ".venv/bin/python"])
        #expect(!result.policy.askFirstCommands.contains("following project symlinks before reviewing targets"))
        #expect(!result.policy.askFirstCommands.contains("dependency installs before reviewing symlinked project metadata"))
        #expect(!result.warnings.contains { $0.hasPrefix("Project symlinks detected") })
    }

    @Test
    func scanAsksBeforePythonCommandsWhenProjectVenvIsBroken() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
        ])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent(".venv"), withIntermediateDirectories: true)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".venv"))
        #expect(!result.project.detectedFiles.contains(".venv/bin/python"))
        #expect(result.project.packageManager == "python")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Python commands before project .venv/bin/python exists"))
        #expect(result.warnings.contains("Project .venv exists, but executable .venv/bin/python was not found; ask before Python commands or recreating the virtual environment."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running Python commands before project .venv/bin/python exists`."))
        #expect(context.contains("Project .venv exists, but executable .venv/bin/python was not found; ask before Python commands or recreating the virtual environment."))
        #expect(!context.contains("Prefer `.venv/bin/python -m pytest`."))
        #expect(!context.contains("Prefer `python3 -m pytest`."))
        #expect(policy.contains("`running Python commands before project .venv/bin/python exists`"))
        #expect(!policy.contains("`python3 -m pytest`"))
        #expect(!policy.contains("`test commands for the selected project`"))
    }

    @Test
    func scanAsksBeforePythonCommandsWhenProjectVenvPythonIsNotExecutable() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
        ])
        try FileManager.default.createDirectory(at: projectURL.appendingPathComponent(".venv/bin"), withIntermediateDirectories: true)
        try "".write(to: projectURL.appendingPathComponent(".venv/bin/python"), atomically: true, encoding: .utf8)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".venv"))
        #expect(!result.project.detectedFiles.contains(".venv/bin/python"))
        #expect(result.project.packageManager == "python")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Python commands before project .venv/bin/python exists"))
        #expect(result.warnings.contains("Project .venv exists, but executable .venv/bin/python was not found; ask before Python commands or recreating the virtual environment."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running Python commands before project .venv/bin/python exists`."))
        #expect(!context.contains("Prefer `.venv/bin/python -m pytest`."))
        #expect(policy.contains("`running Python commands before project .venv/bin/python exists`"))
        #expect(!policy.contains("`.venv/bin/python -m pytest`"))
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
    func scanGuardsPythonProjectsWhenPython3IsMissing() throws {
        let projectURL = try makeProject(files: [
            "requirements.txt": "pytest\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Python commands before python3 is available"))
        #expect(result.policy.askFirstCommands.contains("python3 -m pip install"))
        #expect(result.warnings.contains("Project files prefer Python, but python3 was not found on PATH; ask before running Python commands."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `python3` before running Python commands."))
        #expect(context.contains("Ask before `running Python commands before python3 is available`."))
        #expect(context.contains("Project files prefer Python, but python3 was not found on PATH; ask before running Python commands."))
        #expect(!context.contains("Prefer `python3 -m pytest`."))
        #expect(policy.contains("`running Python commands before python3 is available`"))
        #expect(!policy.contains("`python3 -m pytest`"))
    }

    @Test
    func scanGuardsPythonPipInstallAliases() throws {
        let projectURL = try makeProject(files: [
            "requirements.txt": "pytest\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        for command in [
            "pip install",
            "pip3 install",
            "python -m pip install",
            "python3 -m pip install",
            "pip uninstall",
            "pip3 uninstall",
            "python -m pip uninstall",
            "python3 -m pip uninstall",
            "pip download",
            "pip3 download",
            "python -m pip download",
            "python3 -m pip download",
            "pip wheel",
            "pip3 wheel",
            "python -m pip wheel",
            "python3 -m pip wheel",
            "pip index",
            "pip3 index",
            "python -m pip index",
            "python3 -m pip index",
            "pip search",
            "pip3 search",
            "python -m pip search",
            "python3 -m pip search",
            "pip cache purge",
            "pip3 cache purge",
            "python -m pip cache purge",
            "python3 -m pip cache purge",
            "pip cache remove",
            "pip3 cache remove",
            "python -m pip cache remove",
            "python3 -m pip cache remove",
        ] {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }

        for command in [
            "global pip install",
            "global pip3 install",
            "global python -m pip install",
            "global python3 -m pip install",
            "pip install --user",
            "pip3 install --user",
            "python -m pip install --user",
            "python3 -m pip install --user",
            "pip install --break-system-packages",
            "pip3 install --break-system-packages",
            "python -m pip install --break-system-packages",
            "python3 -m pip install --break-system-packages",
            "pip config list",
            "pip3 config list",
            "python -m pip config list",
            "python3 -m pip config list",
            "pip config get",
            "pip3 config get",
            "python -m pip config get",
            "python3 -m pip config get",
            "pip config debug",
            "pip3 config debug",
            "python -m pip config debug",
            "python3 -m pip config debug",
            "pip config set",
            "pip3 config set",
            "python -m pip config set",
            "python3 -m pip config set",
            "pip config unset",
            "pip3 config unset",
            "python -m pip config unset",
            "python3 -m pip config unset",
            "pip config edit",
            "pip3 config edit",
            "python -m pip config edit",
            "python3 -m pip config edit",
        ] {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `pip install`."))
        #expect(context.contains("Ask before `python3 -m pip install`."))
        #expect(policy.contains("`pip3 install`"))
        #expect(policy.contains("`python -m pip install`"))
        #expect(policy.contains("`pip uninstall`"))
        #expect(policy.contains("`python3 -m pip uninstall`"))
        #expect(policy.contains("`pip download`"))
        #expect(policy.contains("`python3 -m pip wheel`"))
        #expect(policy.contains("`pip index`"))
        #expect(policy.contains("`python3 -m pip search`"))
        #expect(policy.contains("`pip cache purge`"))
        #expect(policy.contains("`python3 -m pip cache remove`"))
        #expect(policy.contains("`pip config set`"))
        #expect(policy.contains("`python3 -m pip config edit`"))
        #expect(policy.contains("`global pip install`"))
        #expect(policy.contains("`global python3 -m pip install`"))
        #expect(policy.contains("`python3 -m pip install --user`"))
        #expect(policy.contains("`python3 -m pip install --break-system-packages`"))
        #expect(policy.contains("`pip config list`"))
        #expect(policy.contains("`python3 -m pip config debug`"))
    }

    @Test
    func scanAsksBeforeVirtualEnvironmentCreationCommands() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let commands = [
            "python -m venv",
            "python3 -m venv",
            "uv venv",
            "virtualenv",
            "creating or deleting virtual environments",
        ]

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in commands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
    }

    @Test
    func scanAsksBeforeUvPipMutationCommands() throws {
        let projectURL = try makeProject(files: [
            "uv.lock": "version = 1\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a uv": .init(name: "/usr/bin/which", args: ["-a", "uv"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/uv", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)
        let commands = [
            "uv sync",
            "uv add",
            "uv remove",
            "uv pip install",
            "uv pip uninstall",
            "uv pip sync",
            "uv pip compile",
        ]

        for command in commands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `uv sync`."))
        #expect(context.contains("Ask before `uv pip install`."))
        #expect(policy.contains("`uv pip uninstall`"))
        #expect(policy.contains("`uv pip sync`"))
        #expect(policy.contains("`uv pip compile`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenPythonDependencySignalsAreMixed() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            "requirements.txt": "pytest\n",
            "requirements-dev.txt": "ruff\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.policy.askFirstCommands.contains("dependency installs before choosing between pyproject.toml and requirements files"))
        #expect(result.warnings.contains("Python dependency files include both pyproject.toml and requirements files; ask before dependency installs until the source of truth is clear."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `dependency installs before choosing between pyproject.toml and requirements files`."))
        #expect(context.contains("Python dependency files include both pyproject.toml and requirements files; ask before dependency installs until the source of truth is clear."))
        #expect(policy.contains("`dependency installs before choosing between pyproject.toml and requirements files`"))
    }

    @Test
    func scanAsksBeforeInstallsWhenUvLockAndRequirementsFilesCoexist() throws {
        let projectURL = try makeProject(files: [
            "uv.lock": "version = 1\n",
            "requirements.txt": "pytest\n",
            "requirements-dev.txt": "ruff\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/which -a uv": .init(name: "/usr/bin/which", args: ["-a", "uv"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/uv", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "uv")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("uv sync"))
        #expect(result.policy.askFirstCommands.contains("uv add"))
        #expect(result.policy.askFirstCommands.contains("uv remove"))
        #expect(result.policy.askFirstCommands.contains("dependency installs before choosing between uv.lock and requirements files"))
        #expect(result.warnings.contains("Python dependency files include both uv.lock and requirements files; ask before dependency installs until the source of truth is clear."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Use `uv` because project files point to it."))
        #expect(!context.contains("Prefer `uv run`."))
        #expect(context.contains("Ask before `dependency installs before choosing between uv.lock and requirements files`."))
        #expect(context.contains("Python dependency files include both uv.lock and requirements files; ask before dependency installs until the source of truth is clear."))
        #expect(!policy.contains("`uv run`"))
        #expect(policy.contains("`dependency installs before choosing between uv.lock and requirements files`"))
    }

    @Test
    func scanResolvesPythonPipAndRubyTooling() throws {
        let projectURL = try makeProject(files: [
            "requirements.txt": "pytest\n",
            "Gemfile": "source \"https://rubygems.org\"\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python --version": .init(name: "/usr/bin/env", args: ["python", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.12.4", stderr: ""),
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.12.4", stderr: ""),
            "/usr/bin/env pip --version": .init(name: "/usr/bin/env", args: ["pip", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "pip 24.0", stderr: ""),
            "/usr/bin/env pip3 --version": .init(name: "/usr/bin/env", args: ["pip3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "pip 24.0", stderr: ""),
            "/usr/bin/env ruby --version": .init(name: "/usr/bin/env", args: ["ruby", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "ruby 3.3.0", stderr: ""),
            "/usr/bin/env gem --version": .init(name: "/usr/bin/env", args: ["gem", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "3.5.0", stderr: ""),
            "/usr/bin/which -a python": .init(name: "/usr/bin/which", args: ["-a", "python"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
            "/usr/bin/which -a pip": .init(name: "/usr/bin/which", args: ["-a", "pip"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pip", stderr: ""),
            "/usr/bin/which -a pip3": .init(name: "/usr/bin/which", args: ["-a", "pip3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pip3", stderr: ""),
            "/usr/bin/which -a ruby": .init(name: "/usr/bin/which", args: ["-a", "ruby"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/ruby", stderr: ""),
            "/usr/bin/which -a gem": .init(name: "/usr/bin/which", args: ["-a", "gem"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/gem", stderr: ""),
            "/usr/bin/which -a bundle": .init(name: "/usr/bin/which", args: ["-a", "bundle"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/bundle", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        for tool in ["python", "python3", "pip", "pip3", "ruby", "gem"] {
            #expect(result.tools.resolvedPaths.contains(where: { $0.name == tool && !$0.paths.isEmpty }), "Expected \(tool) paths in scan_result.json")
            #expect(result.tools.versions.contains(where: { $0.name == tool && $0.available }), "Expected \(tool) version in scan_result.json")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        #expect(scanResult.contains("\"name\" : \"pip3\""))
        #expect(scanResult.contains("\"name\" : \"ruby\""))
        #expect(report.contains("- pip3: /opt/homebrew/bin/pip3"))
        #expect(report.contains("- ruby: /opt/homebrew/bin/ruby"))
    }

    @Test
    func scanResolvesUvAndPyenvPythonTooling() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            "uv.lock": "version = 1\n",
            ".python-version": "3.12\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env uv --version": .init(name: "/usr/bin/env", args: ["uv", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "uv 0.7.2", stderr: ""),
            "/usr/bin/env pyenv --version": .init(name: "/usr/bin/env", args: ["pyenv", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "pyenv 2.5.5", stderr: ""),
            "/usr/bin/which -a uv": .init(name: "/usr/bin/which", args: ["-a", "uv"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/uv", stderr: ""),
            "/usr/bin/which -a pyenv": .init(name: "/usr/bin/which", args: ["-a", "pyenv"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pyenv", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "uv")
        #expect(result.policy.preferredCommands.isEmpty)
        for tool in ["uv", "pyenv"] {
            #expect(result.tools.resolvedPaths.contains(where: { $0.name == tool && !$0.paths.isEmpty }), "Expected \(tool) paths in scan_result.json")
            #expect(result.tools.versions.contains(where: { $0.name == tool && $0.available }), "Expected \(tool) version in scan_result.json")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        #expect(scanResult.contains("\"name\" : \"uv\""))
        #expect(scanResult.contains("\"version\" : \"pyenv 2.5.5\""))
        #expect(report.contains("- uv: /opt/homebrew/bin/uv"))
        #expect(report.contains("- pyenv: pyenv 2.5.5"))
    }

    @Test
    func scanGuardsUvProjectsWhenUvIsMissing() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            "uv.lock": "version = 1\n",
            ".python-version": "3.12\n",
        ])
        try makeExecutableProjectVenvPython(projectURL)

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.12.4", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
            "/usr/bin/which -a pip3": .init(name: "/usr/bin/which", args: ["-a", "pip3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/pip3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "uv")
        #expect(result.project.detectedFiles.contains("uv.lock"))
        #expect(result.project.detectedFiles.contains(".venv/bin/python"))
        #expect(result.policy.preferredCommands == [".venv/bin/python -m pytest"])
        #expect(result.policy.askFirstCommands.contains("running uv commands before uv is available"))
        #expect(result.warnings.contains("Project files prefer uv, but uv was not found on PATH; ask before running uv commands or substituting another package manager."))
        #expect(result.warnings.contains("Project .venv exists; use .venv/bin/python for Python commands before system python3."))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `uv` before running uv commands."))
        #expect(context.contains("Prefer `.venv/bin/python -m pytest`."))
        #expect(context.contains("Ask before `running uv commands before uv is available`."))
        #expect(!context.contains("Prefer `uv run`."))
        #expect(policy.contains("`.venv/bin/python -m pytest`"))
        #expect(!policy.contains("`uv run`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
        #expect(policy.contains("`running uv commands before uv is available`"))
    }

    @Test
    func scanAsksBeforeUvCommandsWhenUvVersionCheckFails() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            "uv.lock": "version = 1\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env uv --version": .init(name: "/usr/bin/env", args: ["uv", "--version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "uv: failed to load"),
            "/usr/bin/which -a uv": .init(name: "/usr/bin/which", args: ["-a", "uv"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/uv", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "uv")
        #expect(result.commands.filter { $0.args == ["uv", "--version"] }.count == 1)
        #expect(result.tools.versions.filter { $0.name == "uv" }.count == 1)
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running uv commands before uv version check succeeds"))
        #expect(!result.policy.askFirstCommands.contains("running uv commands before uv is available"))
        #expect(result.diagnostics.filter { $0 == "uv --version failed with exit code 1: uv: failed to load" }.count == 1)
        #expect(result.tools.versions.contains(where: { $0.name == "uv" && !$0.available }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before `running uv commands before uv version check succeeds`."))
        #expect(context.contains("uv --version failed with exit code 1: uv: failed to load"))
        #expect(!context.contains("Prefer `uv run`."))
        #expect(policy.contains("`running uv commands before uv version check succeeds`"))
        #expect(!policy.contains("`uv run`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
    }

    @Test
    func scanAsksBeforePythonCommandsWhenPythonVersionCheckFails() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 1, durationMs: 1, timedOut: false, available: true, stdout: "", stderr: "python3: failed to load runtime"),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.policy.preferredCommands.isEmpty)
        #expect(result.policy.askFirstCommands.contains("running Python commands before python3 version check succeeds"))
        #expect(result.policy.askFirstCommands.contains("python3 -m pip install"))
        #expect(!result.policy.askFirstCommands.contains("running Python commands before python3 is available"))
        #expect(result.diagnostics.contains("python3 --version failed with exit code 1: python3: failed to load runtime"))
        #expect(result.tools.versions.contains(where: { $0.name == "python3" && $0.available == false }))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Verify `python3` before running Python commands."))
        #expect(context.contains("Ask before `running Python commands before python3 version check succeeds`."))
        #expect(context.contains("python3 --version failed with exit code 1: python3: failed to load runtime"))
        #expect(!context.contains("Use `python` because project files point to it."))
        #expect(!context.contains("Prefer `python3 -m pytest`."))
        #expect(policy.contains("`running Python commands before python3 version check succeeds`"))
        #expect(!policy.contains("`python3 -m pytest`"))
        #expect(!policy.contains("`test commands for the selected project`"))
        #expect(!policy.contains("`build commands for the selected project`"))
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
    func scanDoesNotWarnWhenActivePythonSatisfiesPythonVersion() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            ".python-version": "3.12\n",
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.12.4", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(!result.warnings.contains("Project requests Python 3.12; verify active python before installs (/opt/homebrew/bin/python3)."))
        #expect(!result.policy.askFirstCommands.contains("dependency installs before matching active Python to project version hints"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(!context.contains("Project requests Python 3.12; verify active python before installs"))
    }

    @Test
    func scanUsesToolVersionsForPythonRuntimeInstallGuard() throws {
        let projectURL = try makeProject(files: [
            "pyproject.toml": "[project]\nname = \"demo\"\n",
            ".tool-versions": """
            # asdf-style runtime hints
            python 3.12.4 3.11.9
            ruby 3.3.0
            """,
        ])

        let runner = FakeCommandRunner(results: [
            "/usr/bin/env python3 --version": .init(name: "/usr/bin/env", args: ["python3", "--version"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "Python 3.11.9", stderr: ""),
            "/usr/bin/which -a python3": .init(name: "/usr/bin/which", args: ["-a", "python3"], exitCode: 0, durationMs: 1, timedOut: false, available: true, stdout: "/opt/homebrew/bin/python3", stderr: ""),
        ])

        let result = HabitatScanner(runner: runner).scan(projectURL: projectURL)

        #expect(result.project.packageManager == "python")
        #expect(result.project.detectedFiles.contains(".tool-versions"))
        #expect(result.project.runtimeHints.python == "3.12.4")
        #expect(result.warnings.contains("Active Python is Python 3.11.9, but project requests 3.12.4; ask before dependency installs (/opt/homebrew/bin/python3)."))
        #expect(result.policy.askFirstCommands.contains("dependency installs before matching active Python to project version hints"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Active Python is Python 3.11.9, but project requests 3.12.4; ask before dependency installs"))
        #expect(policy.contains("`dependency installs before matching active Python to project version hints`"))
    }
}
