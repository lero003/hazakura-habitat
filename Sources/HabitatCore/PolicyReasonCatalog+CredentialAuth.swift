extension PolicyReasonCatalog {
    static func isCredentialOrAuthSessionCommand(_ command: String) -> Bool {
        if isCliAuthAndCredentialStoreCommand(command) {
            return true
        }
        if isPackageManagerCredentialAndConfigCommand(command) {
            return true
        }
        if isCloudAndContainerCredentialCommand(command) {
            return true
        }
        if isSshPrivateKeyCommand(command) {
            return true
        }
        return false
    }
}
