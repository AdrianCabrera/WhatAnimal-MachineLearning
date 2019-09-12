//
//  ViewController.swift
//  WhatAnimal
//
//  Created by Adrian Cabrera on 12/09/2019.
//  Copyright © 2019 Adrian Cabrera. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    let sourceType = UIImagePickerController.SourceType.photoLibrary
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if !UIImagePickerController.isSourceTypeAvailable(sourceType){
            
            let alertController = UIAlertController.init(title: nil, message: "Device has no source of type \(sourceType).", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                
                imageView.image = userPickedImage;
                
                guard let ciimage = CIImage(image: userPickedImage) else { fatalError("Could not convert to CIImage") }
                
                detect(image: ciimage)
                
            }
            
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: MyPetImageClassifier().model) else { fatalError("Loading CoreML Model Failed.") }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else { fatalError("Model failed to process image.") }
            self.navigationItem.title = classification.identifier.capitalized
        }

        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        } catch {
            print(error)
        }

    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
}

