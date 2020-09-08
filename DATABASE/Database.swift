//
//  Database.swift
//  AHF
//
//  Created by Nano on 20-06-01.
//

import Foundation

protocol DateDB: Decodable, Encodable {}

protocol Database {
    var version: Int { get }
    
    var user: User { get }
    var locations: Set<Location> { get }
    var arround: Set<Coord> { get }
    var locationsReady: Bool { get }

    func dataLog(_ strArray:String...)
    
    func loadUser()

    func load(user idUser:String, fromDelivery delivery:Delivery)
    func load(event idEvent:String, fromDelivery delivery:Delivery)
    
    func loadLocations()
    func new(event:Event)
    func finish(event:Event)
    func select(event:Event)
    func release(event:Event)
    
    func update(event: Event)

    func update(user:User)
//    func update(event:Event)
    func update(delivery:Delivery)
    
    func createRootUser( onSuccess: @escaping () -> Void )
    func loadRootUser( onFound: @escaping () -> Void,
                       onNotFound: @escaping () -> Void )
    func loadEvents( fromUser:User, onSuccess: @escaping () -> Void )
    func loadDonation( fromUser:User, onSuccess: @escaping () -> Void )
    func loadDeliveries( fromUser:User, onSuccess: @escaping () -> Void )
}
