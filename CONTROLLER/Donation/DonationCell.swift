//
//  GiveTableViewCell.swift
//  AHF
//
//  Created by Nano on 20-06-09.
//

import UIKit

class DonationCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var qty: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
