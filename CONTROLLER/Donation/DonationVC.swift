//
//  DonationVC.swift
//  AHF
//
//  Created by Nano on 20-06-15.
//

import UIKit

class DonationVC: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    
    var bkpQty: Int!
    var bkpText: String!
    var bkpPhoto: UIImage!
    
    var newPhoto: UIImage!
    
    var goingToCamera = false
    var goingToCancel = false
    var donation: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        text.delegate = self
        donation = Model.shared.user.donation

        // Backup data
        bkpQty = donation.qty
        bkpText = donation.text
        bkpPhoto = donation.photo

        // Views
        text.text = donation.text
        photo.image = donation.photo
        qtyLabel.text = String(donation.qty)
        
        enableDeliveryInfo()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !goingToCamera && !goingToCancel else { return }
        
        donation.text = text.text
        donation.photo = photo.image
        
        // Data
        donation.update()
    }

    @IBAction func plusButton(_ sender: Any) {

        donation.qty += 1

        qtyLabel.text = String(donation.qty)
        enableDeliveryInfo()
    }
    @IBAction func minusButton(_ sender: Any) {

        donation.qty -= 1

        qtyLabel.text = String(donation.qty)
        enableDeliveryInfo()
    }
    @IBAction func cancel(_ sender: Any) {
        goingToCancel = true
        donation.text = bkpText
        donation.photo = bkpPhoto
        donation.qty = bkpQty
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func photoButton(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        goingToCamera = true
        present(vc, animated: true)
    }
    
    // MARK: - Protocols
    
    // UIImagePickerControllerDelegate
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            appLog(#function,#line,"No image found")
            goingToCamera = false
            return
        }
        
        donation.photo = image
        photo.image = image
        view.layoutIfNeeded()
        goingToCamera = false
    }
    
    // UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func enableDeliveryInfo() {
        let state = donation.qty > 0

        UIView.animate(withDuration: 1, animations: {
            self.labelText.isHidden    = !state
            self.text.isHidden         = !state
            self.text.isEditable       = state
            self.photo.isHidden        = !state
            self.undoButton.isHidden   = !state
            self.undoButton.isEnabled  = state
            self.photoButton.isHidden  = !state
            self.photoButton.isEnabled = state
        })
    }
}
