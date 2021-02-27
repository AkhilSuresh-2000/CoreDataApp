//
//  ViewController.swift
//  saveDataTue
//
//  Created by Akhil Suresh on 2020-11-24.
//  Copyright © 2020 Akhil Suresh. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController ,UITableViewDelegate , UITableViewDataSource {
   
   
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPaintingName = ""
    var selectedPaintingId : UUID?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //so here we custom added a button
        // this is a bar button item
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtinClick))
                          //So the action needs an fuction so the selector uses objective C so we used the #selector
                        
        getData()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //get data
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPainting"), object:nil)
    }
    
    
    @objc func getData(){
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        //everything we do we is using the context
        let  appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings" )
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    // here it is casted as string and save as an erray
                    //each record read is saved and appened to an array
                    if let name = result.value(forKey: "name") as? String{
                        nameArray.append(name)
                    }
                    //casting the id as UUID and appending into an array
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                    tableView.reloadData()
                }
            }
        }
        catch{
            print("Error")
            
        }
        
        
    }
    
    
    //to show that this is coming from objective C  we put @obj
    
    @objc func addButtinClick(){
        selectedPaintingName = ""
        
        performSegue(withIdentifier: "toDetailVc", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nameArray.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
        
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           selectedPaintingId = idArray[indexPath.row]
           selectedPaintingName = nameArray[indexPath.row]
            performSegue(withIdentifier: "toDetailVc", sender: nil)
       }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            //delete from painting where Id = ??
            let  appdelegate = UIApplication.shared.delegate as! AppDelegate
                   let context = appdelegate.persistentContainer.viewContext
                   
                   let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings" )
            let idString  = idArray[indexPath.row].uuidString
                   fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
                   do{
                       let results = try context.fetch(fetchRequest)
                       if results.count > 0{
                           for result in results as! [NSManagedObject]{
                               // here it is casted as string and save as an erray
                               //each record read is saved and appened to an array
                               if let id = result.value(forKey: "id") as? UUID{
                                
                                
                                if id == idArray[indexPath.row]{
                                    context.delete(result)
                                    nameArray.remove(at: indexPath.row)
                                    idArray.remove(at: indexPath.row)
                                    tableView.reloadData()
                                    do{
                                    
                                        try context.save()
                                    }
                                    catch{
                                        print("Error")
                                    }
                                    break
                                }
                                   
                                  
                               }
                              
                               
                           }
                       }
                   }
                   catch{
                       print("Error")
                       
                   }
            
        }
    }
       
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toDetailVc"{
               let des = segue.destination as! deatilViewController
               des.choosenPaintingId = selectedPaintingId
               des.choosenPaintingName = selectedPaintingName
           }
       }
    
   
 

}


