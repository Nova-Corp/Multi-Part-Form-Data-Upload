//
//  Media.swift
//  ImageUploaderExample
//
//  Created by ADMIN on 21/05/20.
//  Copyright © 2020 Success Resource Pte Ltd. All rights reserved.
//

import Foundation
import UIKit

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage) {
        self.key = "banner"
        self.mimeType = "image/*"
        self.filename = "\(arc4random()).jpg"
        
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        self.data = data
    }
}
