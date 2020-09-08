//
//  MapViewController.swift
//  AHF
//
//  Created by Nano on 20-05-31.
//

import UIKit
import MapKit

class DeliveryVC: UIViewController {

    @IBOutlet weak var mapView: DeliveryMap!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var labelDonation: UILabel!
    @IBOutlet weak var labelRequest: UILabel!
    
    lazy var model = Model.shared!
    lazy var user = Model.shared.db.user

    override func viewDidLoad()
    {
        super.viewDidLoad()

        mapView.model = model
        mapView.delegate = mapView
        mapView.showsUserLocation = true
        mapView.goButton = goButton
        mapView.labelDonation = labelDonation
        mapView.labelRequest = labelRequest
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        mapView.show()
        
    }
}
