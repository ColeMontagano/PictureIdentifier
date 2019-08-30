//
//  ViewController.swift
//  PictureIdentifier
//
//  Created by Cole Montagano on 2019-08-30.
//  Copyright © 2019 Cole Montagano. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userImage
            guard let ciimage = CIImage(image : userImage) else {fatalError("Cant Convert to CI Image")}
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        
    }
    
    func detect(image : CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("Loading Core ML Model Failed")}
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model Failed to Process Image")
            }
            if let firstResult = results.first {
                self.navigationItem.title = "\(Int(firstResult.confidence * 100))% \(firstResult.identifier)"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
       }
        catch{
            print("error")
        }
        
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    

}

