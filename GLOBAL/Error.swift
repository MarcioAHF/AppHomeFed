//
//  Error.swift
//  AHF
//
//  Created by marcio on 2020-06-24.
//

import Foundation

enum DBError: Error {
    case noUserId
    case userNotFound
}

func appLog(_ errorText:Any...) {
    let str = errorText.map { String(describing: $0 ) }
    let msg = Date().description + " " + str.joined(separator: " ")
    print( "Error: \(msg)" )
}
