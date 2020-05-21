//
//  SupportLib.swift
//  ImageUploaderExample
//
//  Created by ADMIN on 21/05/20.
//  Copyright © 2020 Success Resource Pte Ltd. All rights reserved.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
