//
//  ent Coord.swift
//  AHF
//
//  Created by Nano on 20-06-10.
//

import Foundation

class Location: Hashable, CustomStringConvertible {
    
    var coord: Coord!
    var events = Set<Event>()

    init( coord:Coord ) {
        self.coord = coord
    }

    class func get(locationIn:Coord) -> Location? {
        for location in Model.shared.db.locations {
            if location.coord.str == locationIn.str {
                return location
            }
        }
        return nil
    }

    // MARK: CustomStringConvertible
    var description: String {
        return "Location \(coord.description)"
    }

    // Hashable Protocol
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.coord.str == rhs.coord.str
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(coord.str)
    }
}
