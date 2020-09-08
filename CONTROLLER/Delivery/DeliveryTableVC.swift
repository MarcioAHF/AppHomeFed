//
//  DeliveryTableVC.swift
//  AHF
//
//  Created by Nano on 20-06-13.
//

import UIKit

class DeliveryTableVC: UITableViewController {
    
    var qtyRequests = 0
    var qtyDonations = 0
    var user = Model.shared.user
    var selectedDelivery:Delivery!
    lazy var deliveries = Set<Delivery>()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        deliveries = user.activeDeliveries
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.deliveriesCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! DeliveryCell

        let delivery = deliveries[deliveries.index(deliveries.startIndex, offsetBy: indexPath.row)]

        cell.timeLabel.text = delivery.created?.timeAgo() ?? "" + " ago"
        
        if delivery.event.type == .donation {
            cell.nameLabel.text = delivery.event.user.name
            cell.qtyLabel.isHidden = false
            cell.qtyLabel.text = delivery.qty.description
        } else {
            cell.nameLabel.text = ""
            cell.qtyLabel.isHidden = true
        }
        cell.addressLabel.text = delivery.event.text
        cell.icon.image = delivery.event.icon()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDelivery = deliveries[deliveries.index(deliveries.startIndex, offsetBy: indexPath.row)]
        performSegue( withIdentifier: "Destination", sender: self )
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DeliveryDetailVC
        vc.parentVC = self
    }
}
