//
//  ProfileVC.swift
//  AHF
//
//  Created by marcio on 2020-07-03.
//

import UIKit

class ProfileVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var photo: UIImageView!
        
    lazy var user = Model.shared.user
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photo.image = user.photo
        name.text = user.name
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        user.name = name.text ?? ""
        user.update()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            appLog(#function,#line,"No image found")
            return
        }

        user.update(photo:image)
        photo.image = user.photo
        view.layoutIfNeeded()
    }
}

