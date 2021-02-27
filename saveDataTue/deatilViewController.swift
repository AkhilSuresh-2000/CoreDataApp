//
//  deatilViewController.swift
//  saveDataTue
//
//  Created by Akhil Suresh on 2020-11-24.
//  Copyright © 2020 Akhil Suresh. All rights reserved.
//

import UIKit
import CoreData

class deatilViewController: UIViewController ,UIImagePickerControllerDelegate , UINavigationControllerDelegate  {
    
    var choosenPaintingName = ""
    var choosenPaintingId : UUID?
    
    @IBOutlet weak var imgView: UIImageView!
    
    
    @IBOutlet weak var txtName: UITextField!
    
    
    @IBOutlet weak var txtArtist: UITextField!
    
    
    @IBOutlet weak var txtYear: UITextField!
    
    
    @IBOutlet weak var btnSave: UIButton!
    
    
    
    @IBAction func savePressed(_ sender: Any) {
        
        //allowing the user to select the pg]hoto from the gallary
        // step 1 create a recognizer
        
        let  appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(txtName.text!, forKey: "name")
        newPainting.setValue(txtArtist.text!, forKey: "artist")
        
        if let year = Int(txtYear.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        let data = imgView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        newPainting.setValue(UUID(), forKey: "id")
        do{
           try  context.save()
           print("Sucessfull")
        }
        catch{
            
            print("Error")
        }
        
        // we need to create another ethod to relaod the table view beacasue the data is saved but
        // when we go back the datat is not refreshed
        
        //for sending notification to viewController
         // object register with a notification center to recieve notifications
        NotificationCenter.default.post(name:NSNotification.Name("newPainting"), object: nil)
        
        //pops the top view controller
        navigationController?.popViewController(animated: true)
       
        
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        getDataById()
        //this is the recognizer
        imgView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imgView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func chooseImage(){
        
        // this code allows the user to pick an image from the photo libarary
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
        
    }
    //type didfinishpicking to access this  fucntion
    // info here is a dictionary so we havea key and a vlaue
    // inf is the value
    // and infokey is the key
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imgView.image = info[.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func getDataById(){
        if(choosenPaintingName != ""){
            btnSave.isHidden = true
        //everything we do we is using the context
        let  appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings" )
        let idString  = choosenPaintingId?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    // here it is casted as string and save as an erray
                    //each record read is saved and appened to an array
                    if let name = result.value(forKey: "name") as? String{
                        
                        txtName.text = name
                    }
                    //casting the id as UUID and appending into an array
                    if let artist = result.value(forKey: "artist") as? String{
                        txtArtist.text = artist
                    }
                    if let year = result.value(forKey: "year") as? Int{
                                           txtYear.text = String(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data{
                        
                        imgView.image = UIImage(data: imageData)
                    }
                    
                }
            }
        }
        catch{
            print("Error")
            
        }
    }
        
            else{
                btnSave.isHidden = false
            }
        
    }
    
    
    
    

    

}
