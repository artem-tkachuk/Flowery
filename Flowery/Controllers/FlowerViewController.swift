//
//  ViewController.swift
//  Flowery
//
//  Created by Artem Tkachuk on 8/7/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import UIKit
import CoreML
import Vision
import SDWebImage

//MARK: - FlowerViewController
class FlowerViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flowerDescriptionLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var wikipediaManager = WikipediaManager()
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wikipediaManager.delegate = self
        imagePicker.delegate = self
        
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    //MARK: - detect()
    func detect(objectOn pickedImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Loading the CoreML model from FlowerClassifier failed")
        }
        
        let handler = VNImageRequestHandler(ciImage: pickedImage)
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let firstGuess = request.results?.first as? VNClassificationObservation else {
                fatalError("Model failed while processing the image")
            }
            
            let flowerName = firstGuess.identifier
            
            self.navigationItem.title = flowerName
            self.wikipediaManager.getFlowerInfo(for: flowerName)
        }
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    //MARK: - CameraPressed()
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}


//MARK: - WikipediaManagerDelegate
extension FlowerViewController: WikipediaManagerDelegate {
    func didUpdateWikipediaInfo(_ wikipediaManager: WikipediaManager, _ flowerInfo: FlowerModel) {
        DispatchQueue.main.async {
            self.flowerDescriptionLabel.text = flowerInfo.extract
            self.imageView.sd_setImage(with: URL(string: flowerInfo.thumbnail))
        }
    }
    
    //MARK: - failWithError()
    func didFailWithError(_ error: Error) {
        let alertController = UIAlertController(title: "Error while fetching information from Wikipedia", message: "" , preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}


//MARK: - UIImagePickerController
extension FlowerViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickerImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = userPickerImage
            
            //convert to CIImage
            guard let convertedCIImage = CIImage(image: userPickerImage) else {
                fatalError("Could not covert the picked image to CIImage")
            }
            
            detect(objectOn: convertedCIImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

