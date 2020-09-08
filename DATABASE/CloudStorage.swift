//
//  ImageStorage.swift
//  AHF
//
//  Created by marcio on 2020-07-05.
//

import Foundation
import UIKit
import FirebaseStorage

class CloudStorage: FileStorage {
    
    var images = [String:UIImage]()

    lazy var storage = Storage.storage()
    lazy var fs = Model.shared.db as! FirestoreDatabase

    func upload(group:String?, docId:String?, field:String?, image:UIImage?) {
        guard let group = group else {appLog("upload group"); return}
        guard let docId = docId else {appLog("upload docId"); return}
        guard let field = field else {appLog("upload field"); return}
        guard let image = image else {appLog("upload image"); return}

        let key = group+"/"+docId+"-"+field
        
        let fullPath = "e3ve3r5t1/"+key+".png"
        
        let fileRef = self.storage.reference().child(fullPath)
        let pngImage = image.pngData()
        
        fileRef.putData(pngImage!, metadata: nil)
        { (metadata, error) in
            storageQueue.async {
                storageSemaphore.wait()
                
                guard let _ = metadata else {
                    appLog(#function,#line,"Error metadata: \(error?.localizedDescription ?? k.null)")
                    storageSemaphore.signal()
                    return
                }
                self.fs.dataLog("Uploaded: image \(key)")

                self.images[key] = image //downloadURL.absoluteString
             
                storageSemaphore.signal()
            }
        }
    }

    func download(group:String, docId:String, field:String, handler: @escaping (UIImage)->Void) {
            let key = group+"/"+docId+"-"+field
            if let image = self.images[key] {
                handler(image)
                return
            }
            
            let fullPath = "e3ve3r5t1/"+key+".png"
            let fileRef = self.storage.reference().child(fullPath)
            
            fileRef.downloadURL { (url, error) in
                storageQueue.async {
                    storageSemaphore.wait()

                    if let url = url {
                        let data = NSData(contentsOf: url)
                        let image = UIImage(data: data! as Data)
                        self.images[key] = image //downloadURL.absoluteString
                        handler(image!)
                        self.fs.dataLog("Downloaded: image \(key)")
                    } else {
                        appLog(#function,#line,"Error downloadURL: \(error?.localizedDescription ?? k.null)")
                    }
                        
                    storageSemaphore.signal()
                }
            }
    }
}
