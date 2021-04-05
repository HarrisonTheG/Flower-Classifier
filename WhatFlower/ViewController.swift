//
//  ViewController.swift
//  WhatFlower
//
//  Created by Harrison Goenawan on 27/4/20.
//  Copyright © 2020 Harrison. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var label: UILabel!
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("Failed to set user picked image")
        }
        guard let ciimage = CIImage(image: userPickedImage) else {
            fatalError("cannot convert to ciimage")
        }
        
        detect(flowerImage: ciimage)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func requestInfo (flowerName: String) {
        
        let parameters: [String:String] = [
        
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
        Alamofire.AF.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
            if response.error == nil {
                print ("Got the wikipedia info.")
                print (JSON(response.value!))
                
                let flowerJSON : JSON = JSON(response.value!)
                let pageid = flowerJSON["query"]["pageid"][0].stringValue
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                self.label.text = flowerDescription
                self.imageView.sd_setImage(with: URL(string: flowerImageURL), completed: nil)
            }
        }
    }
    
    func detect(flowerImage: CIImage) {
        guard let model = try? VNCoreMLModel (for: FlowerClassifier().model) else {
            fatalError()
        }
        let request = VNCoreMLRequest(model: model) { (request, Error) in
        let result = request.results as? [VNClassificationObservation]
            guard let firstResult = result?.first else {
                fatalError()
            }
            DispatchQueue.main.async{
            self.navigationItem.title = firstResult.identifier.capitalized}
            self.requestInfo(flowerName: firstResult.identifier)
        }
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        do {
            try handler.perform([request])}
          catch {
            fatalError()
        }

    
}

}
