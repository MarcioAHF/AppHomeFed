//
//  Entity.swift
//  AHF
//
//  Created by marcio on 2020-06-27.
//

import Foundation

protocol Entity:Hashable, Comparable, CustomStringConvertible, Encodable, Decodable {
    var id:String? { get set }
    var group:String { get }
}
