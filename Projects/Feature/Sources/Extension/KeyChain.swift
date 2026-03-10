//
//  KeyChain.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Security
import Foundation

public final class KeyChain {

    public static let shared = KeyChain()

    func create(key: String, token: String) {

        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: token.data(using: .utf8, allowLossyConversion: false) as Any
        ]

        SecItemDelete(query)

        let status = SecItemAdd(query, nil)
        assert(status == noErr, "failed to save Token")
    }

    public func read(key: String) -> String? {

        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)

        guard status == errSecSuccess,
              let retrievedData = dataTypeRef as? Data else {
            print("failed to loading, status code = \(status)")
            return nil
        }

        return String(data: retrievedData, encoding: .utf8)
    }

    func updateItem(token: Any, key: Any) -> Bool {

        let prevQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]

        let updateQuery: [CFString: Any] = [
            kSecValueData: (token as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any
        ]

        let status = SecItemUpdate(prevQuery as CFDictionary, updateQuery as CFDictionary)

        if status == errSecSuccess { return true }

        print("updateItem Error : \(status.description)")
        return false
    }

    func delete(key: String) {

        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]

        let status = SecItemDelete(query)

        if status != errSecSuccess {
            print("Failed to delete item from Keychain with status code \(status)")
        }
    }
}

public struct Const {

    public struct KeyChainKey {
        public static let accessToken = "accessToken"
        public static let refreshToken = "refreshToken"
        public static let authority = "authority"
    }
}
