import Foundation

public struct PolicyReasonCode: Codable, Equatable, Sendable {
    public let code: String
    public let text: String

    public init(code: String, text: String) {
        self.code = code
        self.text = text
    }
}

enum PolicyReasonCatalog {
    static func legend(askFirstCommands: [String], forbiddenCommands: [String]) -> [PolicyReasonCode] {
        let usedCodes = Set(
            askFirstCommands.map { askFirstReason(for: $0).code }
                + forbiddenCommands.map { forbiddenReason(for: $0).code }
        )
        return orderedReasonCodes.filter { usedCodes.contains($0.code) }
    }

    static func commandReasons(askFirstCommands: [String], forbiddenCommands: [String]) -> [PolicyCommandReason] {
        findings(askFirstCommands: askFirstCommands, forbiddenCommands: forbiddenCommands)
            .map { PolicyCommandReason(finding: $0) }
    }

    static func findings(askFirstCommands: [String], forbiddenCommands: [String]) -> [PolicyFinding] {
        askFirstCommands.map(askFirstFinding)
            + forbiddenCommands.map(forbiddenFinding)
    }

    static func askFirstCommandReason(for command: String) -> PolicyCommandReason {
        PolicyCommandReason(finding: askFirstFinding(for: command))
    }

    static func forbiddenCommandReason(for command: String) -> PolicyCommandReason {
        PolicyCommandReason(finding: forbiddenFinding(for: command))
    }

    static func askFirstFinding(for command: String) -> PolicyFinding {
        finding(
            command: command,
            classification: PolicyFinding.askFirstClassification,
            reason: askFirstReason(for: command)
        )
    }

    static func forbiddenFinding(for command: String) -> PolicyFinding {
        finding(
            command: command,
            classification: PolicyFinding.forbiddenClassification,
            reason: forbiddenReason(for: command)
        )
    }

    static func askFirstReason(for command: String) -> PolicyReasonCode {
        askFirstReasonRules.first { $0.matches(command) }?.reasonCode.reason
            ?? ReasonCode.userApprovalRequired.reason
    }

    static func forbiddenReason(for command: String) -> PolicyReasonCode {
        forbiddenReasonRules.first { $0.matches(command) }?.reasonCode.reason
            ?? ReasonCode.unsafeOrSensitiveCommand.reason
    }

    private static func finding(
        command: String,
        classification: String,
        reason: PolicyReasonCode
    ) -> PolicyFinding {
        PolicyFinding(
            command: command,
            classification: classification,
            reasonCode: reason.code,
            reason: reason.text
        )
    }

}
