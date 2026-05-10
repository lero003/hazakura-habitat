import Testing
import Foundation
@testable import HabitatCore

struct SecretFilePolicyTests {
    @Test
    func secretBearingEvidenceKeepsSearchExclusionsFilenameOnly() throws {
        let project = ProjectInfo(
            detectedFiles: [
                ".env",
                ".env.example",
                ".env.local",
                ".envrc",
                ".envrc.example",
                ".netrc",
                ".npmrc",
                "README.md",
                "id_ed25519",
                "id_ed25519.pub",
            ],
            symlinkedFiles: [],
            unsafeRuntimeHintFiles: [],
            unsafePackageMetadataFields: [],
            packageManager: nil,
            packageManagerVersion: nil,
            packageManagerVersionSource: nil,
            packageScripts: [],
            runtimeHints: RuntimeHints(node: nil, python: nil)
        )

        let evidence = SecretBearingEvidence(project: project)

        #expect(evidence.paths == [".env", ".env.local", ".envrc", ".netrc", ".npmrc", "id_ed25519"])
        #expect(evidence.environmentValuePaths == [".env", ".env.local", ".envrc"])
        #expect(evidence.hasDotEnvFile)
        #expect(evidence.hasEnvrcFile)
        #expect(evidence.hasNetrcFile)
        #expect(evidence.hasPackageManagerAuthConfig)
        #expect(evidence.hasSSHPrivateKeyFile)
        #expect(!evidence.paths.contains(".env.example"))
        #expect(!evidence.paths.contains(".envrc.example"))
        #expect(!evidence.paths.contains("id_ed25519.pub"))
    }

    @Test
    func scanDetectsProjectCloudAndContainerCredentialFilesWithoutReadingValues() throws {
        let secretValue = "hh_project_cloud_credential_secret"
        let projectURL = try makeProject(files: [
            ".aws/credentials": "[default]\naws_secret_access_key=\(secretValue)\n",
            ".aws/config": "[profile demo]\nsso_session=\(secretValue)\n",
            ".config/gcloud/application_default_credentials.json": "{\"refresh_token\":\"\(secretValue)\"}\n",
            ".docker/config.json": "{\"auths\":{\"example.com\":{\"auth\":\"\(secretValue)\"}}}\n",
            ".kube/config": "users:\n- token: \(secretValue)\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".aws/credentials"))
        #expect(result.project.detectedFiles.contains(".aws/config"))
        #expect(result.project.detectedFiles.contains(".config/gcloud/application_default_credentials.json"))
        #expect(result.project.detectedFiles.contains(".docker/config.json"))
        #expect(result.project.detectedFiles.contains(".kube/config"))
        #expect(result.warnings.contains("Project cloud/container credential files detected (.aws/config, .aws/credentials, .config/gcloud/application_default_credentials.json, .docker/config.json, .kube/config); do not read credential values or print auth tokens."))
        #expect(result.policy.forbiddenCommands.contains("cat .aws/credentials"))
        #expect(result.policy.forbiddenCommands.contains("open .docker/config.json"))
        #expect(result.policy.forbiddenCommands.contains("curl -F file=@.kube/config <url>"))
        #expect(result.policy.forbiddenCommands.contains("project copy, sync, or archive without excluding secret-bearing files"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        let scanResult = try String(contentsOf: outputURL.appendingPathComponent("scan_result.json"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let report = try String(contentsOf: outputURL.appendingPathComponent("environment_report.md"), encoding: .utf8)

        #expect(scanResult.contains("\".aws/credentials\""))
        #expect(context.contains("Do not read, open, copy, upload, or archive local cloud or container credential files, or print cloud auth tokens."))
        #expect(policy.contains("`cat .aws/credentials`"))
        #expect(policy.contains("`open .docker/config.json`"))
        #expect(policy.contains("`curl -F file=@.kube/config <url>`"))
        #expect(report.contains("Project cloud/container credential files detected"))

        for artifact in [scanResult, context, policy, report] {
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("sso_session"))
            #expect(!artifact.contains("refresh_token"))
        }
    }

    @Test
    func agentContextPrioritizesDetectedSecretFileAvoidance() throws {
        let secretValue = "hh_dense_secret_context_value"
        let projectURL = try makeProject(files: [
            ".env": "APP_TOKEN=\(secretValue)\n",
            ".envrc": "export APP_TOKEN=\(secretValue)\n",
            ".netrc": "machine api.example.com password \(secretValue)\n",
            ".npmrc": "//registry.npmjs.org/:_authToken=\(secretValue)\n",
            ".aws/credentials": "[default]\naws_secret_access_key=\(secretValue)\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive `.env` files."))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive `.envrc` files."))
        #expect(context.contains("Do not source or load secret environment files."))
        #expect(context.contains("Do not render Docker Compose config while secret environment files may be interpolated."))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive `.netrc` files."))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive package manager auth config files."))
        #expect(context.contains("Do not read, open, copy, upload, or archive local cloud or container credential files, or print cloud auth tokens."))
        #expect(context.contains("Ask before broad `rg`/`grep -R`/`git grep` unless detected secret-bearing files are excluded; targeted reads of known non-secret source/test files can proceed; start broad search with `rg <pattern> --glob '!.aws/credentials' --glob '!.env' --glob '!.env.*' --glob '!.envrc' --glob '!.envrc.*' --glob '!.netrc'`; add exclusions for remaining detected paths before broad search."))
        #expect(context.contains("Do not copy, sync, or archive the project without excluding detected secret-bearing files."))
        #expect(!context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, archive, or load private keys."))
        #expect(!context.contains(secretValue))
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
            ".npmrc": "//registry.npmjs.org/:_authToken=\(secretValue)\n",
            ".pnpmrc": "//registry.npmjs.org/:_authToken=\(secretValue)\n",
            ".yarnrc.yml": "npmAuthToken: \(secretValue)\n",
            "id_rsa": "\(privateKeyMarker)\n\(secretValue)\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)

        #expect(result.project.detectedFiles.contains(".env"))
        #expect(result.project.detectedFiles.contains(".env.local"))
        #expect(result.project.detectedFiles.contains(".env.example"))
        #expect(result.project.detectedFiles.contains(".npmrc"))
        #expect(result.project.detectedFiles.contains(".pnpmrc"))
        #expect(result.project.detectedFiles.contains(".yarnrc.yml"))
        #expect(result.project.detectedFiles.contains("id_rsa"))
        #expect(result.project.runtimeHints.node == "v20")
        #expect(result.warnings.contains("Environment file exists; do not read .env values."))
        #expect(result.warnings.contains("Package manager auth config exists; do not read token values from npm, yarn, Python, Ruby, Cargo, or Composer package auth config files."))
        #expect(result.warnings.contains("Private key file exists; do not read private key values."))
        #expect(result.policy.forbiddenCommands.contains("read package manager auth config values"))
        #expect(result.policy.forbiddenCommands.contains("read private keys"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)

        for name in ["scan_result.json", "agent_context.md", "command_policy.md", "environment_report.md"] {
            let artifact = try String(contentsOf: outputURL.appendingPathComponent(name), encoding: .utf8)
            #expect(!artifact.contains(secretValue))
            #expect(!artifact.contains("OPENAI_API_KEY"))
            #expect(!artifact.contains("LOCAL_TOKEN"))
            #expect(!artifact.contains("_authToken"))
            #expect(!artifact.contains("npmAuthToken"))
            #expect(!artifact.contains(privateKeyMarker))
        }

        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive `.env` files."))
        #expect(context.contains("Do not source or load secret environment files."))
        #expect(context.contains("Do not render Docker Compose config while secret environment files may be interpolated."))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, or archive package manager auth config files."))
        #expect(context.contains("Do not read, compare, restore, check out, open, edit, copy, move, sync, upload, archive, or load private keys."))
        #expect(policy.contains("`docker compose config`"))
        #expect(policy.contains("`docker-compose config`"))
        #expect(policy.contains("`docker compose config --environment`"))
        #expect(policy.contains("`docker-compose config --environment`"))
        #expect(policy.contains("`docker compose --env-file .env config`"))
        #expect(policy.contains("`docker-compose --env-file .env.local config`"))
        #expect(!context.contains("Do not read `.env` values."))
        #expect(!context.contains("Do not read private keys."))
        #expect(!context.contains("Do not run `read"))
    }

    @Test
    func scanForbidsConcreteDetectedSecretFileAccessCommands() throws {
        let projectURL = try makeProject(files: [
            ".env": "TOKEN=secret\n",
            ".env.example": "TOKEN=\n",
            ".envrc.local": "export TOKEN=secret\n",
            ".netrc": "machine api.example.com password secret\n",
            ".npmrc": "//registry.npmjs.org/:_authToken=secret\n",
            "id_ed25519": "-----BEGIN OPENSSH PRIVATE KEY-----\nsecret\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let sensitiveFiles = [".env", ".envrc.local", ".netrc", ".npmrc", "id_ed25519"]

        for file in sensitiveFiles {
            for command in ["cat \(file)", "less \(file)", "head \(file)", "tail \(file)", "grep <pattern> \(file)", "grep -n <pattern> \(file)", "rg <pattern> \(file)", "rg -n <pattern> \(file)", "rg --line-number <pattern> \(file)", "git grep <pattern> -- \(file)", "git grep -n <pattern> -- \(file)", "git grep <pattern> \(file)", "git grep -n <pattern> \(file)", "sed -n <range> \(file)", "awk <program> \(file)", "diff \(file) <other>", "cmp \(file) <other>", "git diff -- \(file)", "git diff --cached -- \(file)", "git diff --staged -- \(file)", "git diff HEAD -- \(file)", "git diff <rev> -- \(file)", "git diff <rev>..<rev> -- \(file)", "git log -p -- \(file)", "git blame \(file)", "git blame -- \(file)", "git annotate \(file)", "git annotate -- \(file)", "git show -- \(file)", "git show HEAD -- \(file)", "git show <rev> -- \(file)", "git show :\(file)", "git show HEAD:\(file)", "git show <rev>:\(file)", "git cat-file -p :\(file)", "git cat-file -p HEAD:\(file)", "git cat-file -p <rev>:\(file)", "git checkout -- \(file)", "git checkout HEAD -- \(file)", "git checkout <rev> -- \(file)", "git restore -- \(file)", "git restore --staged -- \(file)", "git restore --worktree -- \(file)", "git restore --source HEAD -- \(file)", "git restore --source <rev> -- \(file)", "bat \(file)", "nl -ba \(file)", "base64 \(file)", "xxd \(file)", "hexdump -C \(file)", "strings \(file)", "open \(file)", "code \(file)", "vim \(file)", "vi \(file)", "nano \(file)", "emacs \(file)", "cp \(file) <destination>", "cp -R \(file) <destination>", "cp -r \(file) <destination>", "mv \(file) <destination>", "rsync \(file) <destination>", "rsync -a \(file) <destination>", "scp \(file) <destination>", "curl -F file=@\(file) <url>", "curl --data-binary @\(file) <url>", "curl -T \(file) <url>", "wget --post-file=\(file) <url>", "tar -cf <archive> \(file)", "tar -czf <archive> \(file)", "tar -cjf <archive> \(file)", "tar -cJf <archive> \(file)", "zip <archive> \(file)", "zip -r <archive> \(file)"] {
                #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
            }
        }

        for command in ["ssh-add id_ed25519", "ssh-add -K id_ed25519", "ssh-add --apple-use-keychain id_ed25519", "ssh-keygen -y -f id_ed25519"] {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        for file in [".env", ".envrc.local"] {
            for command in ["source \(file)", ". \(file)"] {
                #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
            }
        }

        for command in ["direnv allow", "direnv reload", "direnv export <shell>", "direnv exec . <command>"] {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        for command in ["render Docker Compose config when secret environment files exist", "docker compose config", "docker-compose config", "docker compose config --environment", "docker-compose config --environment", "docker compose --env-file .env config", "docker-compose --env-file .envrc.local config"] {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        #expect(!result.policy.forbiddenCommands.contains("cat .env.example"))
        #expect(!result.policy.forbiddenCommands.contains("source .env.example"))

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for file in sensitiveFiles {
            #expect(policy.contains("`cat \(file)`"), "Expected command_policy.md to forbid cat \(file)")
            #expect(policy.contains("`grep <pattern> \(file)`"), "Expected command_policy.md to forbid grep <pattern> \(file)")
            #expect(policy.contains("`grep -n <pattern> \(file)`"), "Expected command_policy.md to forbid grep -n <pattern> \(file)")
            #expect(policy.contains("`rg <pattern> \(file)`"), "Expected command_policy.md to forbid rg <pattern> \(file)")
            #expect(policy.contains("`rg -n <pattern> \(file)`"), "Expected command_policy.md to forbid rg -n <pattern> \(file)")
            #expect(policy.contains("`rg --line-number <pattern> \(file)`"), "Expected command_policy.md to forbid rg --line-number <pattern> \(file)")
            #expect(policy.contains("`git grep -n <pattern> -- \(file)`"), "Expected command_policy.md to forbid git grep -n -- \(file)")
            #expect(policy.contains("`git grep -n <pattern> \(file)`"), "Expected command_policy.md to forbid git grep -n \(file)")
            #expect(policy.contains("`sed -n <range> \(file)`"), "Expected command_policy.md to forbid sed -n <range> \(file)")
            #expect(policy.contains("`awk <program> \(file)`"), "Expected command_policy.md to forbid awk <program> \(file)")
            #expect(policy.contains("`diff \(file) <other>`"), "Expected command_policy.md to forbid diff \(file)")
            #expect(policy.contains("`cmp \(file) <other>`"), "Expected command_policy.md to forbid cmp \(file)")
            #expect(policy.contains("`git diff -- \(file)`"), "Expected command_policy.md to forbid git diff \(file)")
            #expect(policy.contains("`git diff --cached -- \(file)`"), "Expected command_policy.md to forbid git diff --cached \(file)")
            #expect(policy.contains("`git diff --staged -- \(file)`"), "Expected command_policy.md to forbid git diff --staged \(file)")
            #expect(policy.contains("`git diff HEAD -- \(file)`"), "Expected command_policy.md to forbid git diff HEAD \(file)")
            #expect(policy.contains("`git diff <rev> -- \(file)`"), "Expected command_policy.md to forbid git diff <rev> \(file)")
            #expect(policy.contains("`git diff <rev>..<rev> -- \(file)`"), "Expected command_policy.md to forbid git diff rev range \(file)")
            #expect(policy.contains("`git log -p -- \(file)`"), "Expected command_policy.md to forbid git log -p \(file)")
            #expect(policy.contains("`git blame \(file)`"), "Expected command_policy.md to forbid git blame \(file)")
            #expect(policy.contains("`git blame -- \(file)`"), "Expected command_policy.md to forbid git blame -- \(file)")
            #expect(policy.contains("`git annotate \(file)`"), "Expected command_policy.md to forbid git annotate \(file)")
            #expect(policy.contains("`git annotate -- \(file)`"), "Expected command_policy.md to forbid git annotate -- \(file)")
            #expect(policy.contains("`git show -- \(file)`"), "Expected command_policy.md to forbid git show -- \(file)")
            #expect(policy.contains("`git show HEAD -- \(file)`"), "Expected command_policy.md to forbid git show HEAD -- \(file)")
            #expect(policy.contains("`git show <rev> -- \(file)`"), "Expected command_policy.md to forbid git show <rev> -- \(file)")
            #expect(policy.contains("`git show :\(file)`"), "Expected command_policy.md to forbid git show :\(file)")
            #expect(policy.contains("`git show HEAD:\(file)`"), "Expected command_policy.md to forbid git show HEAD:\(file)")
            #expect(policy.contains("`git show <rev>:\(file)`"), "Expected command_policy.md to forbid git show <rev>:\(file)")
            #expect(policy.contains("`git cat-file -p :\(file)`"), "Expected command_policy.md to forbid git cat-file index \(file)")
            #expect(policy.contains("`git cat-file -p HEAD:\(file)`"), "Expected command_policy.md to forbid git cat-file HEAD \(file)")
            #expect(policy.contains("`git cat-file -p <rev>:\(file)`"), "Expected command_policy.md to forbid git cat-file revision \(file)")
            #expect(policy.contains("`git checkout -- \(file)`"), "Expected command_policy.md to forbid git checkout -- \(file)")
            #expect(policy.contains("`git checkout HEAD -- \(file)`"), "Expected command_policy.md to forbid git checkout HEAD -- \(file)")
            #expect(policy.contains("`git checkout <rev> -- \(file)`"), "Expected command_policy.md to forbid git checkout <rev> -- \(file)")
            #expect(policy.contains("`git restore -- \(file)`"), "Expected command_policy.md to forbid git restore -- \(file)")
            #expect(policy.contains("`git restore --staged -- \(file)`"), "Expected command_policy.md to forbid git restore --staged -- \(file)")
            #expect(policy.contains("`git restore --worktree -- \(file)`"), "Expected command_policy.md to forbid git restore --worktree -- \(file)")
            #expect(policy.contains("`git restore --source HEAD -- \(file)`"), "Expected command_policy.md to forbid git restore --source HEAD -- \(file)")
            #expect(policy.contains("`git restore --source <rev> -- \(file)`"), "Expected command_policy.md to forbid git restore --source <rev> -- \(file)")
            #expect(policy.contains("`bat \(file)`"), "Expected command_policy.md to forbid bat \(file)")
            #expect(policy.contains("`nl -ba \(file)`"), "Expected command_policy.md to forbid nl -ba \(file)")
            #expect(policy.contains("`base64 \(file)`"), "Expected command_policy.md to forbid base64 \(file)")
            #expect(policy.contains("`xxd \(file)`"), "Expected command_policy.md to forbid xxd \(file)")
            #expect(policy.contains("`hexdump -C \(file)`"), "Expected command_policy.md to forbid hexdump -C \(file)")
            #expect(policy.contains("`strings \(file)`"), "Expected command_policy.md to forbid strings \(file)")
            #expect(policy.contains("`open \(file)`"), "Expected command_policy.md to forbid open \(file)")
            #expect(policy.contains("`code \(file)`"), "Expected command_policy.md to forbid code \(file)")
            #expect(policy.contains("`vim \(file)`"), "Expected command_policy.md to forbid vim \(file)")
            #expect(policy.contains("`nano \(file)`"), "Expected command_policy.md to forbid nano \(file)")
            #expect(policy.contains("`cp \(file) <destination>`"), "Expected command_policy.md to forbid cp \(file)")
            #expect(policy.contains("`mv \(file) <destination>`"), "Expected command_policy.md to forbid mv \(file)")
            #expect(policy.contains("`rsync \(file) <destination>`"), "Expected command_policy.md to forbid rsync \(file)")
            #expect(policy.contains("`scp \(file) <destination>`"), "Expected command_policy.md to forbid scp \(file)")
            #expect(policy.contains("`curl -F file=@\(file) <url>`"), "Expected command_policy.md to forbid curl form upload \(file)")
            #expect(policy.contains("`curl --data-binary @\(file) <url>`"), "Expected command_policy.md to forbid curl data upload \(file)")
            #expect(policy.contains("`curl -T \(file) <url>`"), "Expected command_policy.md to forbid curl transfer upload \(file)")
            #expect(policy.contains("`wget --post-file=\(file) <url>`"), "Expected command_policy.md to forbid wget post-file \(file)")
            #expect(policy.contains("`tar -cf <archive> \(file)`"), "Expected command_policy.md to forbid tar -cf \(file)")
            #expect(policy.contains("`tar -czf <archive> \(file)`"), "Expected command_policy.md to forbid tar -czf \(file)")
            #expect(policy.contains("`tar -cjf <archive> \(file)`"), "Expected command_policy.md to forbid tar -cjf \(file)")
            #expect(policy.contains("`tar -cJf <archive> \(file)`"), "Expected command_policy.md to forbid tar -cJf \(file)")
            #expect(policy.contains("`zip <archive> \(file)`"), "Expected command_policy.md to forbid zip \(file)")
            #expect(policy.contains("`zip -r <archive> \(file)`"), "Expected command_policy.md to forbid zip -r \(file)")
        }

        #expect(policy.contains("`ssh-add id_ed25519`"), "Expected command_policy.md to forbid ssh-add id_ed25519")
        #expect(policy.contains("`ssh-add --apple-use-keychain id_ed25519`"), "Expected command_policy.md to forbid ssh-add --apple-use-keychain id_ed25519")
        #expect(policy.contains("`ssh-keygen -y -f id_ed25519`"), "Expected command_policy.md to forbid ssh-keygen -y -f id_ed25519")

        for file in [".env", ".envrc.local"] {
            #expect(policy.contains("`source \(file)`"), "Expected command_policy.md to forbid source \(file)")
            #expect(policy.contains("`. \(file)`"), "Expected command_policy.md to forbid . \(file)")
        }

        for command in ["direnv allow", "direnv reload", "direnv export <shell>", "direnv exec . <command>"] {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to forbid \(command)")
        }

        #expect(!policy.contains("`cat .env.example`"))
        #expect(!policy.contains("`open .env.example`"))
        #expect(!policy.contains("`diff .env.example <other>`"))
        #expect(!policy.contains("`git diff -- .env.example`"))
        #expect(!policy.contains("`git diff --cached -- .env.example`"))
        #expect(!policy.contains("`git blame .env.example`"))
        #expect(!policy.contains("`git annotate .env.example`"))
        #expect(!policy.contains("`git show -- .env.example`"))
        #expect(!policy.contains("`git show HEAD -- .env.example`"))
        #expect(!policy.contains("`git show :.env.example`"))
        #expect(!policy.contains("`git show <rev>:.env.example`"))
        #expect(!policy.contains("`git cat-file -p :.env.example`"))
        #expect(!policy.contains("`git cat-file -p HEAD:.env.example`"))
        #expect(!policy.contains("`git cat-file -p <rev>:.env.example`"))
        #expect(!policy.contains("`git checkout -- .env.example`"))
        #expect(!policy.contains("`git checkout HEAD -- .env.example`"))
        #expect(!policy.contains("`git checkout <rev> -- .env.example`"))
        #expect(!policy.contains("`git restore -- .env.example`"))
        #expect(!policy.contains("`git restore --staged -- .env.example`"))
        #expect(!policy.contains("`git restore --worktree -- .env.example`"))
        #expect(!policy.contains("`git restore --source HEAD -- .env.example`"))
        #expect(!policy.contains("`git restore --source <rev> -- .env.example`"))
        #expect(!policy.contains("`base64 .env.example`"))
        #expect(!policy.contains("`strings .env.example`"))
        #expect(!policy.contains("`cp .env.example <destination>`"))
        #expect(!policy.contains("`scp .env.example <destination>`"))
        #expect(!policy.contains("`tar -czf <archive> .env.example`"))
        #expect(!policy.contains("`zip -r <archive> .env.example`"))
        #expect(!policy.contains("`source .env.example`"))
    }

    @Test
    func scanAsksBeforeRecursiveSearchWhenSecretBearingProjectFilesExist() throws {
        let projectURL = try makeProject(files: [
            ".env": "TOKEN=secret\n",
            ".env.example": "TOKEN=\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let recursiveSearchCommands = [
            "recursive project search without excluding secret-bearing files",
            "grep -R <pattern> .",
            "grep -r <pattern> .",
            "grep -R -n <pattern> .",
            "grep -r -n <pattern> .",
            "find . -type f -exec grep <pattern> {} +",
            "find . -type f -exec grep -n <pattern> {} +",
            "find . -type f -print0 | xargs -0 grep <pattern>",
            "find . -type f -print0 | xargs -0 grep -n <pattern>",
            "rg <pattern>",
            "rg -n <pattern>",
            "rg <pattern> .",
            "rg -n <pattern> .",
            "rg --line-number <pattern> .",
            "rg --hidden <pattern> .",
            "rg --hidden -n <pattern> .",
            "rg --no-ignore <pattern> .",
            "rg --no-ignore -n <pattern> .",
            "rg -u <pattern> .",
            "rg -uu <pattern> .",
            "rg -uuu <pattern> .",
            "git grep <pattern>",
            "git grep -n <pattern>",
            "git grep <pattern> -- .",
            "git grep -n <pattern> -- .",
        ]

        #expect(
            SecretFileDetector().recursiveSecretSearchAskFirstCommands(result.project)
                == PolicyReasonCatalog.secretBearingBroadSearchCommands,
            "Expected secret-bearing broad-search Ask First generation to use the catalog-owned command family"
        )
        #expect(
            recursiveSearchCommands == PolicyReasonCatalog.secretBearingBroadSearchCommands,
            "Expected this regression fixture to cover the whole catalog-owned broad-search family"
        )

        for command in recursiveSearchCommands {
            #expect(result.policy.askFirstCommands.contains(command), "Expected \(command) to require approval")
            #expect(!result.policy.forbiddenCommands.contains(command), "Did not expect \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        for command in recursiveSearchCommands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
        #expect(policy.contains("- `If Secret-Bearing Files Are Detected` - 1 detected path requiring exclusions before broad search or export."))
        #expect(section(policy, "## If Secret-Bearing Files Are Detected", appearsBefore: "## Allowed"))
        #expect(section(policy, "## If Secret-Bearing Files Are Detected", appearsBefore: "## Forbidden"))
        #expect(policy.contains("- For necessary broad search, start with exclusion-aware `rg`: `rg <pattern> --glob '!.env' --glob '!.env.*'`."))
        #expect(policy.contains("- For necessary Git-tracked search, use pathspec exclusions: `git grep <pattern> -- . ':(exclude).env' ':(exclude).env.*'`."))
        #expect(policy.contains("- Apply equivalent exclusions before broad `grep -R`, `git grep`, copy, sync, or archive commands."))
        #expect(context.contains("Ask before broad `rg`/`grep -R`/`git grep` unless detected secret-bearing files are excluded; targeted reads of known non-secret source/test files can proceed; start broad search with `rg <pattern> --glob '!.env' --glob '!.env.*'`."))

        let exampleOnlyProjectURL = try makeProject(files: [
            ".env.example": "TOKEN=\n",
        ])
        let exampleOnlyResult = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: exampleOnlyProjectURL)

        for command in recursiveSearchCommands {
            #expect(!exampleOnlyResult.policy.askFirstCommands.contains(command), "Did not expect \(command) to require approval when only examples exist")
            #expect(!exampleOnlyResult.policy.forbiddenCommands.contains(command), "Did not expect \(command) when only examples exist")
        }
        let exampleOnlyOutputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: exampleOnlyResult, outputURL: exampleOnlyOutputURL)
        let exampleOnlyPolicy = try String(contentsOf: exampleOnlyOutputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        #expect(!exampleOnlyPolicy.contains("## If Secret-Bearing Files Are Detected"))
        #expect(!exampleOnlyPolicy.contains("For necessary broad search"))
    }

    @Test
    func searchGuidanceShellQuotesSecretBearingPathsWithApostrophes() throws {
        let projectURL = try makeProject(files: [
            "team's.key": "not a real key\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains(#"start broad search with `rg <pattern> --glob '!team'\''s.key'`."#))
        #expect(policy.contains(#"- For necessary broad search, start with exclusion-aware `rg`: `rg <pattern> --glob '!team'\''s.key'`."#))
        #expect(policy.contains(#"- For necessary Git-tracked search, use pathspec exclusions: `git grep <pattern> -- . ':(exclude)team'\''s.key'`."#))
    }

    @Test
    func searchGuidanceMentionsRemainingExclusionsWhenSecretBearingPathsExceedGlobBudget() throws {
        let projectURL = try makeProject(files: [
            ".aws/credentials": "aws_access_key_id = secret\n",
            ".docker/config.json": "{\"auths\":{}}\n",
            ".env": "TOKEN=secret\n",
            ".env.local": "TOKEN=secret\n",
            ".envrc": "export TOKEN=secret\n",
            ".kube/config": "token: secret\n",
            ".netrc": "machine example.test login token\n",
            ".npmrc": "//registry.example.test/:_authToken=secret\n",
            "id_ed25519": "not a real key\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        #expect(context.contains("Ask before broad `rg`/`grep -R`/`git grep` unless detected secret-bearing files are excluded"))
        #expect(context.contains("start broad search with `rg <pattern>"))
        #expect(context.contains("targeted reads of known non-secret source/test files can proceed"))
        #expect(context.contains("; add exclusions for remaining detected paths before broad search."))
        #expect(policy.contains("- Detected secret-bearing paths: .aws/credentials, .docker/config.json, .env, .env.local, .envrc, .kube/config, and 3 more."))
        #expect(policy.contains("- Named source or test files that are not detected secret-bearing paths can be inspected directly."))
        #expect(policy.contains("- For necessary broad search, start with exclusion-aware `rg`: `rg <pattern>"))
        #expect(policy.contains("; add exclusions for remaining detected paths before broad search."))
    }

    @Test
    func scanLeavesRecursiveSearchReadOnlyWhenNoSecretBearingProjectFilesExist() throws {
        let projectURL = try makeProject(files: [
            "Package.swift": "// swift-tools-version: 6.0\n",
            "Sources/App/main.swift": "print(\"hello\")\n",
        ])
        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let recursiveSearchCommands = [
            "recursive project search without excluding secret-bearing files",
            "rg <pattern>",
            "rg -n <pattern>",
            "rg <pattern> .",
            "rg --hidden <pattern> .",
            "grep -R <pattern> .",
            "git grep <pattern>",
            "git grep <pattern> -- .",
        ]

        for command in recursiveSearchCommands {
            #expect(!result.policy.askFirstCommands.contains(command), "Did not expect \(command) to require approval without secret-bearing files")
            #expect(!result.policy.forbiddenCommands.contains(command), "Did not expect \(command) to be forbidden without secret-bearing files")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        #expect(!policy.contains("## If Secret-Bearing Files Are Detected"))
        #expect(!policy.contains("For necessary broad search"))
        #expect(!context.contains("Ask before broad `rg`/`grep -R`/`git grep`"))
        #expect(!context.contains("Do not run broad `rg`/`grep -R`/`git grep`"))
    }

    @Test
    func scanForbidsProjectBulkExportWhenSecretBearingProjectFilesExist() throws {
        let projectURL = try makeProject(files: [
            ".env": "TOKEN=secret\n",
            ".env.example": "TOKEN=\n",
        ])

        let result = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: projectURL)
        let bulkExportCommands = [
            "project copy, sync, or archive without excluding secret-bearing files",
            "cp -R . <destination>",
            "cp -r . <destination>",
            "rsync -a . <destination>",
            "rsync -av . <destination>",
            "ditto . <destination>",
            "tar -cf <archive> .",
            "tar -czf <archive> .",
            "tar -cjf <archive> .",
            "tar -cJf <archive> .",
            "zip -r <archive> .",
            "git archive HEAD",
            "git archive --format=tar HEAD",
            "git archive --format=zip HEAD",
            "git archive -o <archive> HEAD",
            "git archive --output <archive> HEAD",
            "git archive --output=<archive> HEAD",
        ]

        for command in bulkExportCommands {
            #expect(result.policy.forbiddenCommands.contains(command), "Expected \(command) to be forbidden")
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: result, outputURL: outputURL)
        let policy = try String(contentsOf: outputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)
        let context = try String(contentsOf: outputURL.appendingPathComponent("agent_context.md"), encoding: .utf8)

        for command in bulkExportCommands {
            #expect(policy.contains("`\(command)`"), "Expected command_policy.md to include \(command)")
        }
        #expect(policy.contains("## If Secret-Bearing Files Are Detected"))
        #expect(policy.contains("- Detected secret-bearing paths: .env."))
        #expect(policy.contains("- Before recursive search, copy, sync, or archive commands, review exclusions for these paths."))
        #expect(policy.contains("- Named source or test files that are not detected secret-bearing paths can be inspected directly."))
        #expect(policy.contains("- For necessary broad search, start with exclusion-aware `rg`: `rg <pattern> --glob '!.env' --glob '!.env.*'`."))
        #expect(policy.contains("- For necessary Git-tracked search, use pathspec exclusions: `git grep <pattern> -- . ':(exclude).env' ':(exclude).env.*'`."))
        #expect(policy.contains("- Apply equivalent exclusions before broad `grep -R`, `git grep`, copy, sync, or archive commands."))
        #expect(policy.contains("- Prefer targeted source/test inspection over broad `rg`, `grep -R`, `git grep`, `rsync`, `tar`, `zip`, or `git archive` commands."))
        #expect(section(policy, "## If Secret-Bearing Files Are Detected", appearsBefore: "## Ask First"))
        #expect(context.contains("Do not copy, sync, or archive the project without excluding detected secret-bearing files."))

        let exampleOnlyProjectURL = try makeProject(files: [
            ".env.example": "TOKEN=\n",
        ])
        let exampleOnlyResult = HabitatScanner(runner: FakeCommandRunner(results: [:])).scan(projectURL: exampleOnlyProjectURL)
        let exampleOnlyOutputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try ReportWriter().write(scanResult: exampleOnlyResult, outputURL: exampleOnlyOutputURL)
        let exampleOnlyPolicy = try String(contentsOf: exampleOnlyOutputURL.appendingPathComponent("command_policy.md"), encoding: .utf8)

        for command in bulkExportCommands {
            #expect(!exampleOnlyResult.policy.forbiddenCommands.contains(command), "Did not expect \(command) when only examples exist")
        }
        #expect(!exampleOnlyPolicy.contains("## If Secret-Bearing Files Are Detected"))
    }

}
