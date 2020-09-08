//
//  FileStorage.swift
//  AHF
//
//  Created by marcio on 2020-09-01.
//

import Foundation
import UIKit

protocol FileStorage {
    func upload(group:String?, docId:String?, field:String?, image:UIImage?)
    func download(group:String, docId:String, field:String, handler: @escaping (UIImage)->Void)
}

class MockStorage: FileStorage {
    func upload(group:String?, docId:String?, field:String?, image:UIImage?) {}
    
    func download(group:String, docId:String, field:String, handler: @escaping (UIImage)->Void) {}
}
