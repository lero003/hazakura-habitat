extension PolicyReasonCatalog {
    struct CommandFamily: Sendable {
        let commands: [String]
        private let commandSet: Set<String>

        init(_ commands: [String]) {
            self.commands = commands
            self.commandSet = Set(commands)
        }

        func contains(_ command: String) -> Bool {
            commandSet.contains(command)
        }
    }

    struct CommandFamilyManifestEntry: Sendable {
        enum Source: Equatable, Sendable {
            case dynamicAskFirst
            case baselineAskFirst
            case baselineForbidden
        }

        let name: String
        let commands: [String]
        let source: Source

        static func dynamicAskFirst(_ name: String, _ commands: [String]) -> Self {
            Self(name, commands, source: .dynamicAskFirst)
        }

        static func baselineAskFirst(_ name: String, _ commands: [String]) -> Self {
            Self(name, commands, source: .baselineAskFirst)
        }

        static func baselineForbidden(_ name: String, _ commands: [String]) -> Self {
            Self(name, commands, source: .baselineForbidden)
        }

        private init(_ name: String, _ commands: [String], source: Source) {
            self.name = name
            self.commands = commands
            self.source = source
        }
    }
}
