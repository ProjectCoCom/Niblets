import XCTest
@testable import FlashcardAutomation

final class KeychainServiceTests: XCTestCase {

    let keychainService = KeychainService()
    let account = "testAccount"
    let secret = "testSecret".data(using: .utf8)!

    override func tearDown() {
        // Ensure the keychain item is deleted after each test
        try? keychainService.delete(account: account)
        super.tearDown()
    }

    func testSaveAndLoadFromKeychain() throws {
        // This test will only pass in a macOS environment with keychain access.
        #if os(macOS)
        try keychainService.save(account: account, data: secret)
        let loadedSecret = try keychainService.load(account: account)
        XCTAssertEqual(loadedSecret, secret)
        #else
        print("Skipping keychain test on non-macOS platform")
        #endif
    }

    func testDeleteFromKeychain() throws {
        // This test will only pass in a macOS environment with keychain access.
        #if os(macOS)
        try keychainService.save(account: account, data: secret)
        try keychainService.delete(account: account)

        XCTAssertThrowsError(try keychainService.load(account: account)) { error in
            XCTAssertEqual(error as? KeychainError, .itemNotFound)
        }
        #else
        print("Skipping keychain test on non-macOS platform")
        #endif
    }
}
