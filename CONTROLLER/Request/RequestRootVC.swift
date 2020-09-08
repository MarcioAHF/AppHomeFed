//
//  RequestVC.swift
//  AHF
//
//  Created by marcio on 2020-06-23.
//

import UIKit
import MapKit

class RequestRootVC: UIViewController {

    @IBOutlet weak var newRequestImage: UIImageView!
    @IBOutlet weak var oldRequestsImage: UIImageView!
    @IBOutlet weak var newRequestButton: UIButton!
    @IBOutlet weak var oldRequestsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newRequestGesture = UITapGestureRecognizer(target: self, action: #selector(newRequestTap(tapGestureRecognizer:)))
        newRequestImage.isUserInteractionEnabled = true
        newRequestImage.addGestureRecognizer(newRequestGesture)

        let oldRequestGesture = UITapGestureRecognizer(target: self, action: #selector(oldRequestsTap(tapGestureRecognizer:)))
        oldRequestsImage.isUserInteractionEnabled = true
        oldRequestsImage.addGestureRecognizer(oldRequestGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        appLog(#function,#line,"")
    }
    override func viewDidAppear(_ animated: Bool) {
        appLog(#function,#line,"")
        let showPreviousRequests = Model.shared.user.requests.count > 0
        oldRequestsImage.isUserInteractionEnabled = showPreviousRequests
        oldRequestsImage.tintColor = showPreviousRequests ? UIColor.label : UIColor.systemGray2
        oldRequestsButton.isEnabled = showPreviousRequests
        oldRequestsButton.setTitleColor( (showPreviousRequests ? UIColor.label : UIColor.systemGray2), for: .normal)
    }
    @objc func newRequestTap(tapGestureRecognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "NewRequest", sender: nil)
    }
    @objc func oldRequestsTap(tapGestureRecognizer: UITapGestureRecognizer) {
        performSegue(withIdentifier: "OldRequests", sender: nil)
    }
    @IBAction func newRequestButton(_ sender: Any) {
        performSegue(withIdentifier: "NewRequest", sender: nil)
    }
    @IBAction func oldRequestsButton(_ sender: Any) {
        performSegue(withIdentifier: "OldRequests", sender: nil)
    }

}
