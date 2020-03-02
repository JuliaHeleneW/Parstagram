//
//  CameraViewController.swift
//  Parstagram
//
//  Created by user163612 on 2/27/20.
//  Copyright © 2020 user163612. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentField.delegate=self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        let post=PFObject(className: "Posts")
        post["caption"]=commentField.text
        post["author"]=PFUser.current()
        
        let imageData=imageView.image!.pngData()
        let file=PFFileObject(name:"image.png",data:imageData!)
        post["image"]=file
        
        post.saveInBackground { (success, error) in
            if success{
                self.dismiss(animated: true, completion: nil)
                print("Saved!")
            }
            else{
                print("Error!")
            }
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker=UIImagePickerController()
        picker.delegate=self
        picker.allowsEditing=true
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }
        else{
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image=info[.editedImage] as? UIImage{
            let size=CGSize(width: 300, height: 300)
            let scaledImage=image.af_imageScaled(to:size)
            imageView.image=scaledImage
            dismiss(animated: true, completion: nil)
        }
        else{
            print("Error: Image could not be picked.")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
