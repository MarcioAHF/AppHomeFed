//
//  MockDatabase.swift
//  AHF
//
//  Created by Nano on 20-06-03.
//

import Foundation
import UIKit

class MockDatabase: Database {

    static let shared = MockDatabase()
    let notifCenter = NotificationCenter.default
    init() {
        self.user = User()
    }
    func createRootUser(onSuccess: @escaping () -> Void) {}
    func loadRootUser(onFound: @escaping () -> Void,
                      onNotFound: @escaping () -> Void) {}
    func loadEvents( fromUser:User, onSuccess: @escaping () -> Void ) {}
    func loadDonation( fromUser:User, onSuccess: @escaping () -> Void ) {}
    func loadDeliveries(fromUser user:User, onSuccess: @escaping () -> Void) {}

    func loadTestData() {
        let step = 0.0001.dec
        let gps = GPS.shared
        
        // R1
        let r1 = Event( ofType:.request,
                        at:Coord(lat: gps.lat+step, long: gps.long+step) )
        r1.text = "R1 Av. Ask For 1"
        new( event: r1 )
        
        // D1
        let d1 = Event( ofType:.donation,
                        at:Coord(lat: gps.lat+step, long: gps.long-step) )
        d1.qty = 5
        d1.text = "D100 Donation 1"
        new( event: d1 )
        
        // U2
        let u2 = User()// name: "User 2", photo: UIImage(named: "asset2")! )
        
        // U2-T-R1
        let t1 = Delivery(user: u2, event: r1, qty: 1)
        u2.deliveries.insert( t1 )
        r1.deliveries.insert( t1 )
        
        // U2-T-D1
        let t2 = Delivery(user: u2, event: d1, qty: 1)
        u2.deliveries.insert( t2 )
        d1.deliveries.insert( t2 )
        
        // R2
        let r2 = Event(user:u2, ofType:.request,
                       at:Coord(lat: gps.lat-step, long: gps.long+step))
        //        r2.photo = UIImage(named: "House2")
        r2.text = "22 Rue de la Request 2"
        new(event: r2)
        
        // D2
        let d2 = Event(user:u2, ofType:.donation,
                       at:Coord(lat: gps.lat-step, long: gps.long-step))
        d2.qty = 3
        d2.text = "222 Boul. Donation"
        new(event: d2)
        
        // U1-T-R2
        let t3 = Delivery(user: self.user, event: r2, qty: 1)
        self.user.deliveries.insert( t3 )
        r2.deliveries.insert( t3 )
        
        // U1-T-D2
        let t4 = Delivery(user: self.user, event: d2, qty: 1)
        self.user.deliveries.insert( t4 )
        d2.deliveries.insert( t4 )
    }

    // MARK: Protocol
    var version: Int = 1 //TODO: need to test
    
    var user: User
    var locations: Set<Location> = []
    var arround: Set<Coord> = []
    var locationsReady: Bool { get {
        return (locations.count > 0)
        }
    }

    func dataLog(_ strArray:String... ) {
        version += 1
    }
    func loadUser() {}

    func load(user idUser:String, fromDelivery delivery:Delivery) {}
    func load(event idEvent:String, fromDelivery delivery:Delivery) {}

    func loadLocations() {}
    func new( event:Event ) {
        version += 1
        event.user.events.insert(event)

        if let location = Location.get(locationIn: event.coord!) {
            location.events.insert(event)
        } else {
            let location = Location( coord: event.coord! )
            location.events.insert(event)
            self.locations.insert(location)
        }
        
        if event.type == .donation {
            event.user.donation = event
        }
    }
    func finish( event:Event ) {
        version += 1
        event.user.events.remove(event)
    }
    func select( event:Event ) {

        let t = Delivery(user: self.user, event: event, qty: 1)
        self.user.deliveries.insert( t )
        event.deliveries.insert( t )

        version += 1
        notifCenter.post(name: .dbDelivery , object: nil)
    }
    func release( event:Event ) {
        
        let t = event.deliveries.first(where: {$0.event.id == event.id})!
        t.user.deliveries.remove(t)
        event.deliveries.remove(t)
        
        version += 1
        notifCenter.post(name: .dbDelivery , object: nil)
    }

    func update( event:Event ) {}

    func update( user:User ) {}

    func update( delivery:Delivery ) {}
}
