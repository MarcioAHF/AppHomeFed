//
//  ent User.swift
//  AHF
//
//  Created by Nano on 20-06-09.
//

import Foundation
import FirebaseFirestoreSwift

class User: Entity {
    var group = "users"

    // MARK: - Data
    var id: String? {
        didSet {
            if let _ = id {
                downloadPhoto()
            }
        }
    }
    var name: String = ""
    var photo: UIImage?
    @ServerTimestamp var created = Date()
    
    // MARK: - Relationships
    var events = Set<Event>()
    var deliveries = Set<Delivery>()

    // MARK: - Instance
    var donation: Event!
    var requests: Set<Event> {
        return self.events.filter { $0.status == .active && $0.type == .request }
    }
    var donations: Set<Event> {
        return self.events.filter { $0.type == .donation }
    }
    var onGoingRequestsCount: Int {
        return deliveries
            .filter({$0.event != nil})
            .filter({$0.status == .active && $0.event.type == .request})
            .count
    }
    var onGoingDonationsCount: Int {
        return deliveries
            .filter({$0.event != nil})
            .filter({$0.status == .active && $0.event.type == .donation})
            .count
    }
    var deliveriesCount: Int {
        return deliveries.filter({$0.status == .active}).count
    }
    var activeDeliveries:Set<Delivery> {
        return deliveries.filter({$0.status == .active})
    }
    
    init() {
    }
    
    func update() {
        Model.shared.db.update(user: self)
    }
    func update(photo:UIImage) {
        self.photo = photo
        Model.shared.imageStorage.upload(group: group, docId: id!, field: k.id, image: photo )
    }
    func downloadPhoto() {
        Model.shared.imageStorage.download(group: group, docId: self.id!, field: k.id)
        { (image) in self.photo = image }
    }
    
    // MARK: - Protocol
    
    // Decodable
    enum CodingKeys: String, CodingKey {
        case name
        case created
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        name    = try values.decode(String.self, forKey: .name)
        created = try values.decode(Date.self, forKey: .created)
    }

    // CustomStringConvertible
    var description: String {
        var result = "User \( (id ?? k.null).prefix(3) ) [\(name)]"
        result += " \(created?.int ?? 0)"
        result += " [events:\(events.count)]"
        result += " [deliveries:\(deliveries.count.description)]"
        return result
    }
    
    // Hashable
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Comparable
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.id! < rhs.id!
    }
}
