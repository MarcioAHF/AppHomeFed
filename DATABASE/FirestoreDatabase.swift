//
//  DatabaseFirestore.swift
//  M2
//
//  Created by marcio on 2020-06-19.
//

import Foundation
import Firebase

class DateFS: Timestamp, DateDB {
    
}

class Counter {
    var counter:[Int] = [0]
    var completionHandler:(() -> Void)?
    func up(_ idx:Int, _ up:Int = 1, reset:Bool=false) {
        resize(idx)
        counter[idx] = (reset ? 0 : counter[idx]) + up
    }
    func down(_ idx:Int, _ down:Int = 1) {
        resize(idx)
        counter[idx] -= down
        if counter.reduce(0, { (a,b) in a + abs(b) }) == 0 {
            completionHandler?()
        }
    }
    func resize(_ idx:Int) {
        if idx+1 > counter.count {
            counter += Array(repeating: 0, count: (idx+1-counter.count))
        }
    }
}

class FirestoreDatabase: Database {

    // DATA
    var user: User = User()
    var locations = Set<Location>()
    
    // INSTANCE
    static let shared = FirestoreDatabase()
    let fs = Firestore.firestore()
    var version: Int = 0
    var arround = Set<Coord>()
    var locationsReady: Bool { get {
        return (locations.count > 0 && counterLocation.counter.reduce(0,+) == 0)
        }
    }
    
    var counterLocation = Counter()

    init() {
    }
    //------------------------------------------------------------------------------
    func dataLog(_ strArray:String... ) {
        version += 1
    }
    //------------------------------------------------------------------------------
    func createRootUser(onSuccess: @escaping () -> Void) {
        
        let defaults = UserDefaults.standard
        // New User
        var ref: DocumentReference? = nil
        do {
            try ref = self.fs.collection(k.users).addDocument(from: self.user)
            { err in
                dbQueue.async {
                    dbSemaphore.wait()
                    if let err = err {
                        appLog(#function,#line,"\(#function): Error adding document: \(err)")
                    } else {
                        self.user.id = ref!.documentID
                        defaults.set(self.user.id, forKey: k.idUser)
                        self.dataLog("created: \(String(describing: ref?.path))")
                        onSuccess()
                    }
                    dbSemaphore.signal()
                }
            }
        } catch let error {
            appLog(#function,#line,"\(#function): Error writing city to Firestore: \(error)")
        }
    }
    func loadRootUser(onFound: @escaping () -> Void,
                      onNotFound: @escaping () -> Void) {
        fs.collection(k.users).document(self.user.id!).getDocument
            { (DocumentSnapshot, error) in
                dbQueue.async {
                    dbSemaphore.wait()
                    if let entity = self.getDoc( DocumentSnapshot!, error, User.self ) {
                        self.user.name = entity.name
                        self.dataLog("Loaded: \(entity)")
                        onFound()
                    } else {
                        onNotFound()
//                        createRootUser(closure: {print("***CLOSURE***")})
                    }
                    dbSemaphore.signal()
                }
        }
    }

    func loadEvents( fromUser:User, onSuccess: @escaping () -> Void ) {
        forEachDoc(in: fs.collection(k.users).document(user.id!).collection(k.events))
        { (docSnap) in
            self.fs.collection(k.events).document(docSnap.documentID)
                .getDocument { (docSnap, error) in
                    dbQueue.async {
                        dbSemaphore.wait()
                        if let entity = self.getDoc( docSnap!, error, Event.self ) {
                            entity.user = fromUser
                            fromUser.events.insert(entity)
                            self.dataLog("Loaded: \(entity)")
                            onSuccess()
                        }
                        dbSemaphore.signal()
                    }
            }
        }
    }
    func loadDonation( fromUser:User, onSuccess: @escaping () -> Void ) {
        fs.collection(k.users).document(fromUser.id!).collection(k.events).whereField(k.type, isEqualTo: EventType.donation.rawValue)
            .getDocuments() { (querySnapshot, err) in
                dbQueue.async {
                    dbSemaphore.wait()
                    if let err = err {
                        appLog(#function,#line,"Error getting documents: \(err)")
                    } else {
                        var found = false
                        for document in querySnapshot!.documents {
                            if let donation = self.getDoc( document, err, Event.self ) {
                                found = true
                                fromUser.donation = donation
                                self.dataLog("Loaded: \(donation)")
                                onSuccess()
                            }
                        }
                        if !found {
                            self.new(event: Event(ofType: .donation, at: GPS.shared.coord2d))
                        }
                    }
                    dbSemaphore.signal()
                }
        }
    }
    func loadDeliveries( fromUser:User, onSuccess: @escaping () -> Void) {
        forEachDoc(in: fs.collection(k.users).document(fromUser.id!).collection(k.deliveries))
        { (docSnap) in
            self.fs.collection(k.deliveries).document(docSnap.documentID)
                .getDocument { (docSnap, error) in
                    dbQueue.async {
                        dbSemaphore.wait()
                        if let delivery = self.getDoc( docSnap!, error, Delivery.self ) {
                            fromUser.deliveries.insert(delivery)
                            self.dataLog("Loaded: \(delivery)")
                            onSuccess()
                        }
                        dbSemaphore.signal()
                    }
            }
        }
    }
    func loadUser() {}
    //------------------------------------------------------------------------------
    func load(user idUser:String, fromDelivery delivery:Delivery) {
        fs.collection(k.users).document(idUser).getDocument { (DocumentSnapshot, error) in
            if let newUser = self.getDoc( DocumentSnapshot!, error, User.self ) {
                newUser.id = DocumentSnapshot!.documentID
                delivery.user = newUser
                self.dataLog("Loaded: \(newUser)")
            }
        }
    }
    //------------------------------------------------------------------------------
    func load(event idEvent:String, fromDelivery delivery:Delivery) {
        fs.collection(k.events).document(idEvent).getDocument { (DocumentSnapshot, error) in
            if let newEvent = self.getDoc( DocumentSnapshot!, error, Event.self ) {
                newEvent.id = DocumentSnapshot!.documentID
                delivery.event = newEvent
                self.dataLog("Loaded: \(newEvent)")
            }
        }
    }
    //------------------------------------------------------------------------------
    func loadLocations() {
        updateLocationsNearBy()
    }
    //------------------------------------------------------------------------------
    func new(event: Event) {

        func insert(event:Event, intoLocation location:Location) {
            if let existingLocation = self.locations.intersection(Set<Location>([location])).first {
                existingLocation.events.insert(event)
                self.dataLog("Loaded: \(event) into existing \(existingLocation)")
            } else {
                self.locations.insert(location)
                self.dataLog("Loaded: new \(location)")
                location.events.insert(event)
                self.dataLog("Loaded: \(event) into new \(location)")
            }
        }
        func setLocationFor(event:Event, idx:Int=0,
                            _ lastCoord:[Int]=[0,0,0,0],
                            coll:CollectionReference?)  {
            
            var currentCoord = lastCoord
            var baseColl: CollectionReference
            if coll != nil {
                baseColl = coll!
            } else {
                baseColl = fs.collection(k.locations)
            }
            
            do {
                let docId = String(event.coord!.array[idx])
                let docRef = baseColl.document( docId )
                try docRef.setData( [k.coordField[idx]: event.coord!.array[idx] ] )
                { err in
                    if let err = err {
                        appLog(#function,#line,"Error adding document: \(err)")
                    } else {
                        self.dataLog("created: \(docRef.path)")
                        // Recursion stop condition
                        if idx < 3 {
                            currentCoord[idx] = Int(docId)!
                            setLocationFor(event: event,
                                idx: idx+1, currentCoord,
                                coll: (docRef.collection(k.loc)) //coordField[idx]))
                            )
                        } else {
                            currentCoord[idx] = Int(docId)!
                            let location = Location(coord: Coord(array:currentCoord))
                            insert(event: event, intoLocation: location)

                            let eventDocRef = docRef.collection(k.events).document(event.id!)
                            eventDocRef.setData([k.exists:true])
                            self.dataLog("created: \(eventDocRef.path)")
                        }

                    }
                }
            } catch let error {
                appLog(#function,#line,"Error writing city to Firestore: \(error)")
            }
        }

        dbQueue.async {
            dbSemaphore.wait()
            var ref: DocumentReference? = nil
            do {
                try ref = self.fs.collection(k.events).addDocument(from: event)
                { err in
                    if let err = err {
                        appLog(#function,#line,"Error adding document: \(err)")
                    } else {
                        self.dataLog("created: \(String(describing: ref?.path))")
                        event.id = ref!.documentID

                        // Instance data
                        self.user.events.insert(event)
                        event.user = self.user

                        if event.type == .donation {
                            self.user.donation = event
                        }

                        // User -> Event
                        let docRef = self.fs
                            .collection(k.users).document(self.user.id!)
                            .collection(k.events).document(event.id!)
                        docRef.setData( [k.exists: true] )
                        self.dataLog("created: \(String(describing: docRef.path))")

                        // Location -> Event
                        setLocationFor(event: event, coll: nil)
                    }
                    dbSemaphore.signal()
                }
            } catch let error {
                appLog(#function,#line,"Error writing city to Firestore: \(error)")
            }
        }
        
    }
    //------------------------------------------------------------------------------
    func finish(event: Event) {
        let coord = event.coord?.array.map { String($0) }

        fs.collection(k.locations)
            .document(coord![0]).collection(k.loc)
            .document(coord![1]).collection(k.loc)
            .document(coord![2]).collection(k.loc)
            .document(coord![3]).collection(k.events)
            .document(event.id!).delete()
        
        var ref: DocumentReference? = nil
        ref = fs.collection(k.events).document(event.id!)
        ref?.updateData([k.status:Status.inactive.rawValue])
        dataLog("finished: \(String(describing: ref?.path))")
    }
    //------------------------------------------------------------------------------
    func select(event: Event) {
        let newDelivery = Delivery(user: self.user, event: event, qty: 1)

        // Instance data
        self.user.deliveries.insert(newDelivery)
        event.deliveries.insert(newDelivery)
        self.dataLog("Loaded: \(newDelivery)")
        
        dbQueue.async {
            dbSemaphore.wait()
            var ref: DocumentReference? = nil
            do {
                try ref = self.fs.collection(k.deliveries).addDocument(from: newDelivery)
                { err in
                    if let err = err {
                        appLog(#function,#line,"Error adding document: \(err)")
                    } else {
                        self.dataLog("created: \(ref?.path ?? k.null)")
                        newDelivery.id = ref!.documentID
                        
                        // User -> Delivery
                        var docRef = self.fs
                            .collection(k.users).document(self.user.id!)
                            .collection(k.deliveries).document(newDelivery.id!)
                        docRef.setData( [k.idEvent: event.id!] )
                        self.dataLog("created: \(String(describing: docRef.path))")

                        // Event -> Delivery
                        docRef = self.fs
                            .collection(k.events).document(event.id!)
                            .collection(k.deliveries).document(newDelivery.id!)
                        docRef.setData( [k.idUser: self.user.id!] )
                        self.dataLog("created: \(String(describing: docRef.path))")
                    }
                    dbSemaphore.signal()
                }
            } catch let error {
                appLog(#function,#line,"Error writing city to Firestore: \(error)")
            }
        }
    }
    //------------------------------------------------------------------------------
    func release(event: Event) {


        dbQueue.async {
            dbSemaphore.wait()

            var idDelivery = ""
            self.fs.collection(k.events).document(event.id!)
            .collection(k.deliveries).whereField(k.idUser, isEqualTo: self.user.id!)
            .getDocuments()
            { (querySnapshot, err) in
                if let err = err {
                    appLog(#function,#line,"Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                                                
                        idDelivery = document.documentID
                        
                        // Delete Delivery
                        var docRef = self.fs.collection(k.deliveries).document(idDelivery)
                        docRef.delete()
                        self.dataLog("deleted: \(String(describing: docRef.path))")

                        // Delete Event-Delivery
                        docRef = self.fs.collection(k.events).document(event.id!)
                            .collection(k.deliveries).document(idDelivery)
                        docRef.delete()
                        self.dataLog("deleted: \(String(describing: docRef.path))")

                        // Delete User-Delivery
                        docRef = self.fs.collection(k.users).document(self.user.id!)
                            .collection(k.deliveries).document(idDelivery)
                        docRef.delete()
                        self.dataLog("deleted: \(String(describing: docRef.path))")

                    }
                }
                dbSemaphore.signal()
            }
        }
    }
    //------------------------------------------------------------------------------
    func update(event: Event) {
        do {
            let refDoc = self.fs.collection(k.events).document(event.id!)
            try refDoc.setData(from: event)
            { err in
                dbQueue.async {
                    dbSemaphore.wait()
                    if let err = err {
                        appLog(#function,#line,"Error setData for event [\(String(describing: event.id))]: \(err)")
                    } else {
                        self.dataLog("updated: \(refDoc.path)")
                    }
                    dbSemaphore.signal()
                }
            }
        } catch (let error) {
            appLog(#function,#line,error)
        }
    }
    //------------------------------------------------------------------------------
    func update(user:User) {
        do {
            try fs.collection(k.users).document(user.id!).setData(from: user)
            self.dataLog("Updated: \(user)")
        } catch let error {
            appLog(#function,#line,"Error writing user to Firestore: \(error)")
        }
    }
    func update(delivery:Delivery) {
        do {
            try fs.collection(k.deliveries).document(delivery.id!).setData(from: delivery)
            self.dataLog("Updated: \(delivery)")
        } catch let error {
            appLog(#function,#line,"Error writing user to Firestore: \(error)")
        }
    }
    //------------------------------------------------------------------------------
    @objc func updateLocationsNearBy() {
        locationsNearBy(coll:nil)
    }
    //------------------------------------------------------------------------------
    func locationsNearBy(coord:Coord = GPS.shared.coord2d, _ idx:Int = 0,
                         _ lastLocationCoord:[Int]=[0,0,0,0],
                         coll:CollectionReference?) {

        var currentLocationCoord = lastLocationCoord
        let baseColl = (coll != nil) ? coll! : fs.collection(k.locations)
        let inArea = coord.minMaxNearBy() //(coord: coord)

        if idx == 0 {
            counterLocation.up(0,1,reset:true)
            counterLocation.completionHandler = { NotificationCenter.default.post(name: .dbLocation , object: nil) }
        } else {
            counterLocation.up(0)
        }
        baseColl
        .whereField(k.coordField[idx], isGreaterThanOrEqualTo: inArea[idx][0])
        .whereField(k.coordField[idx],    isLessThanOrEqualTo: inArea[idx][1])
        .getDocuments()
        { (querySnapshot, err) in
            guard err != nil else { appLog(#function,#line,"Error getDocuments: \(String(describing: err))"); return }
            guard querySnapshot != nil else { appLog(#function,#line,"Location not found"); return }

            if idx < 3 {
                self.counterLocation.up(1,querySnapshot!.documents.count)
                for doc in querySnapshot!.documents {
                    currentLocationCoord[idx] = Int(doc.documentID)!
                    self.locationsNearBy(coord: coord, idx+1, currentLocationCoord, coll: baseColl.document(doc.documentID).collection(k.loc))
                    self.counterLocation.down(1)
                }
            } else {
                self.counterLocation.up(2,querySnapshot!.documents.count)
                for lastLocationDoc in querySnapshot!.documents {
                    currentLocationCoord[idx] = Int(lastLocationDoc.documentID)!
                    let location = Location(coord: Coord(array:currentLocationCoord))
                    self.locations.insert(location)
                    self.dataLog("Loaded: \(location)")
                    lastLocationDoc.reference.collection(k.events).getDocuments()
                    { (querySnapshot, err) in
                        if let err = err {
                            appLog("Error getting documents: \(err)")
                        } else {
                            self.counterLocation.up(3,querySnapshot!.documents.count)
                            for eventDoc in querySnapshot!.documents {
                                let eventRef = self.fs.collection(k.events).document(eventDoc.documentID)
                                eventRef.getDocument
                                { (snapEvent, error) in
                                    if snapEvent == nil {
                                        appLog("Event \(eventDoc.documentID) from location \(currentLocationCoord) not found")
                                        return
                                    }
                                    var eventToBeAdded:Event?
                                    if let existingEvent = self.user.events.first(where: {$0.id == snapEvent?.documentID}) {
                                        eventToBeAdded = existingEvent
                                    } else {
                                        eventToBeAdded = self.getDoc( snapEvent!, error, Event.self )
                                    }
                                    if eventToBeAdded != nil {
                                        location.events.insert( eventToBeAdded! )
                                        self.dataLog("Loaded: \(eventToBeAdded)")
                                    }
                                    self.counterLocation.down(3)
                                }
                            }
                        }
                        self.counterLocation.down(2)
                    }
                }
            }
            self.counterLocation.down(0)
        }
    }
    //------------------------------------------------------------------------------
    func forEachDoc(in collection:CollectionReference, completion: @escaping  ((DocumentSnapshot)->Void)) {
        collection.getDocuments
        { (querySnapshot, error) in
            dbQueue.async {
                dbSemaphore.wait()
                
                if let snapshotDocuments = querySnapshot?.documents {
                    for snapDoc in snapshotDocuments {
                        completion(snapDoc)
                    }
                }
                
                dbSemaphore.signal()
            }
        }
    }
    //------------------------------------------------------------------------------
    func getDoc<T:Entity>(_ snapDoc:DocumentSnapshot,_ err:Error?,_ type: T.Type ) -> T? {
        let result = Result {
            try snapDoc.data(as: T.self)
        }
        switch result {
        case .success(let object):
            if var object = object {
                object.id = snapDoc.documentID
                //print("\(#function): Insert entity \(object)")
                return object
            } else {
                appLog(#function,#line,"\(#function): Document does not exist")
            }
        case .failure(let error):
            appLog(#function,#line,"\(#function): Error decoding event \(snapDoc.documentID): \(error)")
        }
        return nil
    }
    //------------------------------------------------------------------------------
    func deleteDatabase() {

        func deleteCollection(coll:CollectionReference){
            dbQueue.async {
                dbSemaphore.wait()
                coll.getDocuments { (snap,err) in
                    for doc in snap!.documents {
                        self.dataLog("deleted: \(doc.reference.path)")
                        doc.reference.delete()
                    }
                    dbSemaphore.signal()
                }
            }
        }
        func deleteLocations(_ idx:Int = 0,
                             _ lastLocationCoord:[Int]=[0,0,0,0],
                             coll:CollectionReference?) {

            dbQueue.async {
                if idx == 0 {
                    dbSemaphore.wait()
                }
                var coord = lastLocationCoord
                let baseColl = (coll != nil) ? coll! : self.fs.collection(k.locations)
                baseColl.getDocuments()
                { (querySnapshot, err) in
                    if idx < 3 {
                        for doc in querySnapshot!.documents {
                            coord[idx] = Int(doc.documentID)!
                            deleteLocations(idx+1, coord, coll: doc.reference.collection(k.loc))
                        }
                    } else {
                        for lastLocationDoc in querySnapshot!.documents {
                            coord[idx] = Int(lastLocationDoc.documentID)!
                            deleteCollection(coll: lastLocationDoc.reference.collection(k.events))
                            
                            var coll = self.fs.collection(k.locations)
                                .document(coord[0].str).collection(k.loc)
                                .document(coord[1].str).collection(k.loc)
                                .document(coord[2].str).collection(k.loc)
                                .document(coord[3].str).collection(k.loc)
                            deleteCollection(coll: coll)
                            self.dataLog("deleted: \(coll.path)")
                            
                            coll = self.fs.collection(k.locations)
                                .document(coord[0].str).collection(k.loc)
                                .document(coord[1].str).collection(k.loc)
                                .document(coord[2].str).collection(k.loc)
                            deleteCollection(coll: coll)
                            self.dataLog("deleted: \(coll.path)")
                            
                            coll = self.fs.collection(k.locations)
                                .document(coord[0].str).collection(k.loc)
                                .document(coord[1].str).collection(k.loc)
                            deleteCollection(coll: coll)
                            self.dataLog("deleted: \(coll.path)")
                            
                            coll = self.fs.collection(k.locations)
                                .document(coord[0].str).collection(k.loc)
                            deleteCollection(coll: coll)
                            self.dataLog("deleted: \(coll.path)")
                            
                            dbQueue.async {
                                dbSemaphore.wait()
                                let doc = self.fs.collection(k.locations).document(coord[0].str)
                                self.dataLog("deleted: \(doc.path)")
                                doc.delete()
                                dbSemaphore.signal()
                            }
                        }
                    }
                    dbSemaphore.signal()
                }
            }
        }

        forEachDoc(in: fs.collection(k.events)) { (DocumentSnapshot) in
            deleteCollection(coll: self.fs.collection(k.events).document(DocumentSnapshot.documentID).collection(k.deliveries))
        }

        deleteCollection(coll: fs.collection(k.events))
        deleteCollection(coll: fs.collection(k.deliveries))
        deleteCollection(coll: fs.collection(k.users).document(user.id!).collection(k.events))
        deleteCollection(coll: fs.collection(k.users).document(user.id!).collection(k.deliveries))

        deleteLocations(coll: nil)
        
        self.user.deliveries.removeAll()
        self.user.events.removeAll()
        self.locations.removeAll()
        
    }
}
