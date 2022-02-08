//
//  Digest+Helpers.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 08/02/2022.
//  Copyright © 2022 One Minute Games. All rights reserved.
//

import Foundation
import CryptoKit

extension Digest {
    public var bytes: [UInt8] { Array(makeIterator()) }
    public var data: Data { Data(bytes) }

    public var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
