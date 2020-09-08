//
//  ent Delivery.swift
//  AHF
//
//  Created by Nano on 20-06-09.
//

import Foundation
import UIKit.UIImage
import FirebaseFirestoreSwift

class Delivery: Entity {
    
    // Data
    var id      : String?
    var idUser  : String! {
        didSet {
            if user == nil {
                if idUser == db.user.id {
                    user = db.user
                } else {
                    db.load(user:idUser, fromDelivery:self)
                }
            }
        }
    }
    var idEvent : String! {
        didSet {
            if event == nil {
                db.load(event:idEvent, fromDelivery:self)
            }
        }
    }
    var status  : Status = .active
    var qty     : Int!
    @ServerTimestamp var created = Date()

    // Relationship
    var user : User!
    var event: Event!

    // Instance only
    var photo   : UIImage!
    var group   = "deliveries"
    var db      = Model.shared.db
    var storage = Model.shared.imageStorage

    // MARK: -
    init() {}
    init( user:User, event:Event, qty:Int ) {
        self.user = user
        self.idUser = user.id
        self.event = event
        self.idEvent = event.id
        self.qty = qty
    }
    init( id:String ) {
        self.id = id
    }
    
    func finish() {
        self.status = .inactive
        event.finish(withDelivery:self)
        db.update(delivery:self)
        storage.upload(group: group, docId: id!, field: k.id, image: photo)
    }

    // MARK: - Protocols

    // Decodable
    enum CodingKeys: String, CodingKey {
        case idUser
        case idEvent
        case status
        case qty
        case created
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        idUser   = try values.decode(String.self, forKey: .idUser)
        idEvent  = try values.decode(String.self, forKey: .idEvent)
        status   = try Status(rawValue: values.decode(String.self, forKey: .status))!
        qty      = try values.decode(   Int.self, forKey: .qty)
        created  = try values.decode(  Date.self, forKey: .created)
    }

    // CustomStringConvertible
    var description: String {
        var result = "Delivery \( (id ?? k.null).prefix(3) )"
        result += " \(status)"
        if let _ = event {
            result += " \(k.typeDesc[event.type] ?? k.null)=\( (event.id ?? k.null).prefix(3) )"
        }
        result += " \(created?.int ?? 0)"
        result += " user=\( (user?.id ?? k.null).prefix(3) )"
        result += " qty=\( qty ?? 0 )"
        return result
    }

    // Hashable Protocol
    static func == (lhs:Delivery,rhs:Delivery) -> Bool {return lhs.id==rhs.id}
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    
    // Comparable Protocol
    static func < (lhs: Delivery, rhs: Delivery) -> Bool {
        return lhs.id! < rhs.id!
    }
}
