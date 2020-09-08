//
//  DeliveryDetailVC.swift
//  AHF
//
//  Created by Nano on 20-06-14.
//

import UIKit

class DeliveryDetailVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var text: UITextView!

    var parentVC: DeliveryTableVC!

    lazy var db = Model.shared.db
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photo.image = parentVC.selectedDelivery.event.photo
        text.text = parentVC.selectedDelivery.event.text
        if text.text.count == 0 {
           text.text = "No address information"
        }
        
        if parentVC.selectedDelivery.event.type == .donation {
            name.text = parentVC.selectedDelivery.event.user.name
            name.isHidden = false
        } else {
            name.isHidden = true
        }
    }
    @IBAction func cancelDestination(_ sender: Any) {
        
        // Data
        parentVC.selectedDelivery.event.release()

        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func destinationNotFound(_ sender: Any) {

        let refreshAlert = UIAlertController(
            title: "CANCEL DESTINATION",
            message: "Destination not found",
            preferredStyle: .alert
        )
        
        refreshAlert.addAction(
            UIAlertAction(
                title: "Confirm",
                style: .default,
                handler: {
                    (_)->Void in

                    // Data
                    self.parentVC.selectedDelivery.event.release()

                    self.navigationController?.popToRootViewController(animated: true)
                }
            )
        )
        
        refreshAlert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: {
                    (_)->Void in print("Cancel")
                }
            )
        )
        
        refreshAlert.view.isUserInteractionEnabled = true
        self.present(refreshAlert, animated: true, completion: nil)
        
    }
    
    // MARK: - Camera
    @IBAction func finishTrip(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }

        // Data
        self.parentVC.selectedDelivery.photo = image
        self.parentVC.selectedDelivery.finish()

        self.navigationController?.popToRootViewController(animated: true)
    }
}
