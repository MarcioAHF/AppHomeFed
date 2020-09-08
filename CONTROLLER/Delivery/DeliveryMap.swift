//
//  TakeMap.swift
//  AHF
//
//  Created by Nano on 20-06-01.
//

import UIKit
import MapKit

class DeliveryMap: MKMapView, MKMapViewDelegate {
    
    var gps = GPS.shared
    var model: Model!
    var user = Model.shared.db.user
    
    var eventsAnnotation:[MKPointAnnotation:Event] = [:]
    
    var observing = false

    var dbVersion = -1
    
    var goButton: UIButton!
    var labelDonation: UILabel!
    var labelRequest: UILabel!

    let annotationId = "eventAnnotation"

    func show() {
        
        if gps.ready {
            showEvents()
        }
        if !observing {
            NotificationCenter.default.addObserver(self, selector: #selector(self.showEvents), name: .gps, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.showEvents), name: .dbLocation, object: nil)
            observing = true
        }
    }

    @objc func showEvents() {

        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: gps.currentLocation.coordinate, span: span)

        setRegion(region, animated: true)

        self.removeAnnotations(self.annotations)
        eventsAnnotation.removeAll()
        
        for location in model.db.locations {
            for event in location.events {
                let myDeliveries = event.deliveries.filter({ $0.idUser == user.id }).count //?? 0
                if event.status == .inactive ||
                    (event.type == .donation && event.qtyAvailable < 1 && myDeliveries == 0) {
                    continue
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = event.coord!.asCLLocationCoordinate2D
                addAnnotation( annotation )
                eventsAnnotation[annotation] = event
            }
        }
        showAnnotations(annotations, animated: true)
        updateView()
    }
    func updateView() {
        labelRequest.text  = user.onGoingRequestsCount.description
        labelDonation.text = user.onGoingDonationsCount.description
        goButton.isEnabled = user.deliveriesCount > 0
    }

    // :MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard !(view.annotation is MKUserLocation) else { return }

        let event = eventsAnnotation[view.annotation as! MKPointAnnotation]!
        
        event.isSelected ? event.release() : event.select()
        view.image = event.icon() //icon(forEvent: event)

        updateView()

        deselectAnnotation(view.annotation, animated: true)
        return
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView: MKAnnotationView?
        if let av = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) {
            annotationView = av
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation,
                                      reuseIdentifier: annotationId)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            let event = eventsAnnotation[annotation as! MKPointAnnotation]!
            annotationView.image = event.icon() //icon(forEvent: event)
        }
    
        return annotationView
    }
}
