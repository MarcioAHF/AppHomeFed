//
//  Event.swift
//  AHF
//
//  Created by Nano on 20-06-13.
//

import Foundation
import UIKit.UIImage
import FirebaseFirestoreSwift

class Event: Entity {
    
    var group = "events" //:Entity
    
    // MARK: - Data
    var id:      String? { didSet {
        if uploadPending, let _ = photo {
            Model.shared.imageStorage.upload(group:group, docId: id!, field: k.id, image: photo!)
            uploadPending = false
        } else {
            Model.shared.imageStorage.download(group:group, docId: self.id!, field: k.id)
            { (image) in self.photo = image }
        }}
    }
    var typeInt: Int = 0
    var coordStr:String = ""
    var idUser:  String?
    var text:    String = ""
    var status:  Status = .active
    var qty:     Int = 0
    @ServerTimestamp var created = Date()

    // Instance Data
    var photo:   UIImage?
    var coord:   Coord?
    var type:    EventType = .request
    
    // Instance Relationship Data
    var user: User!
    var deliveries = Set<Delivery>()

    // Model Attributes
    lazy var db = Model.shared.db
    lazy var imageStorage = Model.shared.imageStorage
    var qtyDeliveries: Int { return activeDeliveries.reduce(0, {$0 + $1.qty}) }
    var qtyAvailable: Int { return qty - qtyDeliveries }
    var isSelected: Bool { return deliveries.filter({$0.user.id == db.user.id && $0.status == .active}).count > 0 }
    var deliveriesCount: Int { return activeDeliveries.count }
    var activeDeliveries:Set<Delivery> { return deliveries.filter({$0.status == .active}) }

    var uploadPending = false

    // MARK: -
    init( user:User, ofType:EventType, at:Coord ) {
        self.idUser = user.id
        self.typeInt = ofType.rawValue
        self.coordStr = at.str
        
        self.type = ofType
        self.user = user
        self.coord = at
    }
    
    convenience init( ofType:EventType, at:Coord ) {
        self.init( user: Model.shared.db.user, ofType: ofType, at: at )
    }

    func select() {
        db.select( event:self )
    }
    func release() {
        // Instance data
        if let oldDelivery = self.deliveries.first(where: {$0.idUser == self.user.id}) {
            self.user.deliveries.remove(oldDelivery)
            self.deliveries.remove(oldDelivery)
            oldDelivery.status = .inactive
            db.dataLog("Removed: \(oldDelivery)")
        } else {
            appLog(#function,#line,"Error: oldDelivery not found")
        }

        db.release( event:self )
    }
    func finish(withDelivery delivery:Delivery) {
        if type == .request {
            status = .inactive
            db.finish(event: self)
        } else {
            qty -= delivery.qty
            if qtyAvailable <= 0 {
                db.finish(event: self)
            } else {
                update()
            }
        }
    }
    func update() {
        db.update(event: self)
        imageStorage.upload(group: group, docId: id, field: k.photo, image: photo)
    }
    func icon() -> UIImage {
        if isSelected {
            return UIImage(systemName: (type == .request) ? "house.fill" : "cart.fill")!
        } else {
            return UIImage(systemName: (type == .request) ? "house" : "cart")!
        }
    }

        
    // MARK: - Protocol
    // Decodable Protocol
    enum CodingKeys: String, CodingKey {
        case typeInt = "type"
        case coordStr = "coord"
        case idUser
        case text
        case status
        case qty
        case created
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        coord    = try Coord(str: values.decode(String.self, forKey: .coordStr))
        type     = try EventType(rawValue: values.decode(Int.self, forKey: .typeInt))!
        idUser   = try values.decode(String.self, forKey: .idUser)
        text     = try values.decode(String.self, forKey: .text)
        status   = try Status(rawValue: values.decode(String.self, forKey: .status))!
        qty      = try values.decode(Int.self, forKey: .qty)
        created  = try values.decode(Date.self, forKey: .created)

        coordStr = coord!.str
        typeInt  = type.rawValue
    }

    // CustomStringConvertible Protocol
    var description: String {
        var result = ""
        result += "\(k.typeDesc[type] ?? k.null)"
        result += " \(status)"
        result += " \(created?.int ?? 0)"
        result += " id=\( (id ?? k.null).prefix(3) )"
        result += " user=\( (user?.id ?? k.null).prefix(3) )"
        result += " qty=\( qty )"
        return result
    }
    
    // Hashable Protocol
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Comparable Protocol
    static func < (lhs: Event, rhs: Event) -> Bool {
        return lhs.id! < rhs.id!
    }

}

