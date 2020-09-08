//
//  DonateTableView.swift
//  AHF
//
//  Created by Nano on 20-06-12.
//

import UIKit

class DonationTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    lazy var user = Model.shared.db.user
    lazy var version = Model.shared.version
    
    var dbVersion = 0

    var takers = [User:Int]()
    var users = [User]()
    var qtys = [Int]()
    var qtyDonations:Int = 0
    
    lazy var deliveries = user.donation.activeDeliveries

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.donation?.deliveriesCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:DonationCell = tableView.dequeueReusableCell(withIdentifier: "GiveTableViewCell", for: indexPath) as! DonationCell
        
        let delivery = deliveries[ deliveries.index(
            deliveries.startIndex, offsetBy: indexPath.row ) ]

        cell.photo.image = delivery.user.photo ?? UIImage(systemName: "person.fill")
        cell.qty.text = delivery.qty.description
        cell.name.text = delivery.user.name
        cell.time.text = delivery.created?.timeAgo() ?? "" + " ago"
        
        return cell
    }
}
