//
//  DeliveryCell.swift
//  AHF
//
//  Created by Nano on 20-06-13.
//

import UIKit

class DeliveryCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
    }
}
