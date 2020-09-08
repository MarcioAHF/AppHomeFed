//
//  model.swift
//  AHF
//
//  Created by Nano on 20-05-26.
//

import Foundation
import UIKit
import MapKit

class Model: CustomStringConvertible {

    // Singleton
    static var shared:Model!
    static func shared( withDB: Database, fileStorage: FileStorage ) -> Model {
        Model.shared = Model( withDb: withDB, fileStorage: fileStorage )
        return Model.shared
    }
    
    // Data
    var imageStorage: FileStorage

    var db: Database
    var version: Int { get { return db.version } }
    var user: User { get { return db.user } }
    var locationsReady: Bool { get { return db.locationsReady } }
    var eventsAround: Set<Event> {
        var _eventsAround = Set<Event>()
        for loc in db.locations {
            _eventsAround = _eventsAround.union(loc.events)
        }
        return _eventsAround
    }
    var dbHasChanged = { ( dbVersion:inout Int) -> Bool in
        let result = dbVersion < Model.shared.version
        dbVersion = Model.shared.version
        return result
    }
    
    
    private init( withDb:Database, fileStorage: FileStorage ) {
        db = withDb
        imageStorage = fileStorage
        NotificationCenter.default.addObserver(self,
                                selector: #selector(self.coordinatesAvailable),
                                name: .gps, object: nil)
    }

    // MARK: -
    func new(event:Event) {
        db.new(event: event)
    }
    func finish(event:Event) {
        db.finish(event: event)
    }

    func printDB() {
        dbQueue.async {
            dbSemaphore.wait()
            print( self )
            dbSemaphore.signal()
        }

    }
    // MARK: -
    var description: String {
        get {
            var result = ""
            result += "Version \(String(describing: self.db.version))\n"
            
            result += "\(self.user) \n"
            for event in self.user.events {
                result += "\t\(event) \n"
                for delivery in event.deliveries {
                    result += "\t\t\(delivery) \n\n"
                }
            }
            for delivery in self.user.deliveries ?? [] {
                result += "\t\(delivery) \n"
            }
            
            for location in self.db.locations {
                result += "\n\(location) \n"
                for event in location.events {
                    result += "\t\(event) \n"
                }
            }

            return result
        }
    }

    @objc func coordinatesAvailable() {
        
    }
    
    func initialLoad() {
        UserDefaults.standard.set(nil, forKey: k.idUser)
        loadUserFromDefault()
    }
    
    func loadUserFromDefault() {

        if UserDefaults.standard.object(forKey: k.idUser) != nil {
            db.user.id = UserDefaults.standard.string(forKey: k.idUser)!
            
            loadRootUser(
                   onFound: { self.loadEvents() },
                onNotFound: { self.createRootUser() }
            )

        } else {

            createRootUser()

        }
    }
    
    func createRootUser() {
        db.createRootUser(
            onSuccess: {
                self.loadRootUser(
                       onFound: { self.loadEvents() },
                    onNotFound: { appLog(#function,#line,"\(#function): User not found") }
                )
            }
        )
    }
    
    func loadRootUser(onFound: @escaping () -> Void,
                   onNotFound: @escaping () -> Void) {
        db.loadRootUser(onFound:onFound, onNotFound:onNotFound)
    }
    func loadEvents() {
        db.loadEvents( fromUser: db.user,
                       onSuccess: {self.loadDonation()})
    }
    func loadDonation() {
        db.loadDonation( fromUser: db.user,
                         onSuccess: {self.loadDeliveries()})
    }
    func loadDeliveries() {
        db.loadDeliveries( fromUser: db.user,
                           onSuccess: {})
    }
}
