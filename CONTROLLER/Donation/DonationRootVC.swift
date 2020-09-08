//
//  DonationVC.swift
//  AHF
//
//  Created by Nano on 20-06-18.
//

import UIKit

class DonationRootVC: UIViewController {

    @IBOutlet weak var table: DonationTableView!
    @IBOutlet weak var qtyButton: UIButton!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var chevron: UIButton!
    
    lazy var donation = Model.shared.user.donation
    var dbVersion = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Model.shared.user.donation == nil {
            appLog(#function,#line,"Error: user.donation NIL")
        }

        let goDonationGesture = UITapGestureRecognizer(target: self, action: #selector(goDonationTap(tapGestureRecognizer:)))
        icon.isUserInteractionEnabled = true
        icon.addGestureRecognizer(goDonationGesture)

        if self.donation!.qty <= 0 && self.donation!.qtyDeliveries == 0 {
            self.goDonationVC()
        }
    }
    
    @objc func goDonationTap(tapGestureRecognizer: UITapGestureRecognizer) {
        goDonationVC()
    }

    @IBAction func goDonationVC () {
        performSegue(withIdentifier: "DonationVC", sender: nil)
    }
    override func viewDidAppear(_ animated: Bool) {

        qtyButton.setTitle( String(donation?.qtyAvailable ?? 0), for: .normal)

        if Model.shared.dbHasChanged(&dbVersion) {
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
    }
}

