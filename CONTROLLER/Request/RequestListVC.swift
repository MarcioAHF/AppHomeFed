//
//  MyRequestsViewController.swift
//  AHF
//
//  Created by Nano on 20-06-08.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}

class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var sectionHeaderlabel: UILabel!
}

class RequestListVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var model = Model.shared!
    var user = Model.shared.db.user
    lazy var events = Array(user.requests) //[Event]()

    var dbVersion = 0
    let reuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Model.shared.dbHasChanged(&dbVersion) {
            DispatchQueue.main.async {
                self.events = Array(self.user.requests)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource protocol
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return events.count //user.requests.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MyCollectionViewCell
        
        if let photo = events[indexPath.row].photo {
            cell.image.image = photo
        } else {
            cell.image.image = UIImage(systemName: "photo.fill")
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let refreshAlert = UIAlertController(title: "Cancel Request",
                                             message: "Confirm cancelation of this request?",
                                             preferredStyle: .alert)
        
        refreshAlert.addAction(
            UIAlertAction(title: "No, keep it",
                          style: .default))
        
        refreshAlert.addAction(
            UIAlertAction(title: "Yes, cancel",
                          style: .cancel,
                          handler: {(_)->Void
                            in
                            appLog(#function,#line,"Canceling request")

                            // Data
                            self.model.finish( event:self.events[ indexPath.row ] )

                            self.navigationController?.popToRootViewController(animated: true)
            }
        ))
        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "SectionHeader",
            for: indexPath) as? SectionHeader {
            sectionHeader.sectionHeaderlabel.text = "Section \(indexPath.section)"
            return sectionHeader
        }
        return UICollectionReusableView()
    }
}
