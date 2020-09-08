//
//  AskViewController.swift
//  AHF
//
//  Created by Nano on 20-06-05.
//

import UIKit
import Firebase
import MapKit

class RequestVC: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

//    @IBOutlet weak var buttonPhoto: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var text: UITextView!
        
    var observing = false
    lazy var gps = GPS.shared
    let notif = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        text.delegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(RequestVC.saveTapped))
    }

    @objc func saveTapped(){
        let newRequest = Event( ofType: .request, at: gps.coord2d )
        newRequest.text = text.text
        if photo.image != nil {
            newRequest.photo = photo.image
            newRequest.uploadPending = true
        }

        // Data
        Model.shared.new( event: newRequest )
        
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func photoButton(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            appLog(#function,#line,"No image found")
            return
        }

        photo.image = image
        view.layoutIfNeeded()
    }
    // UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
