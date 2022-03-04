//
//  ViewController.swift
//  ImageUploaderExample
//
//  Created by ADMIN on 19/05/20.
//  Copyright © 2020 Success Resource Pte Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var quoteField: UITextField!
    @IBOutlet weak var bannerView: UIImageView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    
    var baseURL = "https://your.url"
    var bearerTok = "Bearer Tok"
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chooseImageButton.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 0.5)
        chooseImageButton.layer.masksToBounds = true
        chooseImageButton.layer.cornerRadius = 2.0
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
    }
    
    @IBAction func createButton(_ sender: Any) {
        
        if quoteField.text == "" {
            self.view.makeToast("Please enter the quote.")
            return
        }
        if titleField.text == "" {
            self.view.makeToast("Please enter the title.")
            return
        }
        guard let banner = bannerView.image else {
            self.view.makeToast("Please choose the banner.")
            return
        }
        
        createPost(quoteStr: quoteField.text!, bannerImg: banner, titleStr: titleField.text!, speakerId: "8")
    }
    
    @objc func chooseImage(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            bannerView.image = image
            chooseImageButton.setTitle("Change picture", for: .normal)
            chooseImageButton.setBackgroundImage(nil, for: .normal)
            chooseImageButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1.0)
            chooseImageButton.layer.cornerRadius = 8
            chooseImageButton.layer.masksToBounds = true
            
        }
        dismiss(animated: true)
    }
    
}

extension ViewController {
    
    func getBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBody(param: [String: String]?, media: [Media]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = param {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for banner in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(banner.key)\"; filename=\"\(banner.filename)\"\(lineBreak)")
                body.append("Content-Type: \(banner.mimeType + lineBreak + lineBreak)")
                body.append(banner.data)
                body.append(lineBreak)
            }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    func createPost(quoteStr: String, bannerImg: UIImage, titleStr: String, speakerId: String) {
        self.view.makeToastActivity(.center)
        
        let parameters = ["quote": "\(quoteStr)",
                          "title": "\(titleStr)",
                          "speakerid": "\(speakerId)"]
        
        guard let mediaImage = Media(withImage: bannerImg) else { return }
        
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = getBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(bearerTok, forHTTPHeaderField: "Authorization")
        
        let dataBody = createBody(param: parameters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    DispatchQueue.main.async {
                        self.view.hideAllToasts(includeActivity: true, clearQueue: true)
                        self.view.makeToast(String(describing: json))
                    }
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
