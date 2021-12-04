//
//  ListViewController.swift
//  TravelBookApp
//
//  Created by Furkan Öztürk on 30.11.2021.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    var choosenName = ""
    var choosenId : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonCliced))
        
        navigationController?.navigationBar.topItem?.title = "TravelBook List"
        // Do any additional setup after loading the view.
        GetData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(GetData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    @objc func GetData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationsEntitiy")
        request.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(request)
            if results.count > 0{
                self.idArray.removeAll(keepingCapacity: false)
                self.nameArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        nameArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idArray.append(id)
                    }
                }
            }
        }
        catch{
            Helper.Alert(title: "Hata...", message: "Kayıt Getirme İşlemi Sırasında Hata",hasReturn:false,over:self)
        }
        
        tableView.reloadData()

    }
    
    @objc func addButtonCliced(){
        choosenName = ""
        performSegue(withIdentifier: "toDetailView", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenName = nameArray[indexPath.row]
        choosenId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailView", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView"
        {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = self.choosenName
            destinationVC.selectedId = self.choosenId
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationsEntitiy")
                    
                    let idString = idArray[indexPath.row].uuidString
                    
                    fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
                    
                    fetchRequest.returnsObjectsAsFaults = false
                    
                    do {
                    let results = try context.fetch(fetchRequest)
                        if results.count > 0 {
                            
                            for result in results as! [NSManagedObject] {
                                
                                if let id = result.value(forKey: "id") as? UUID {
                                    
                                    if id == idArray[indexPath.row] {
                                        context.delete(result)
                                        nameArray.remove(at: indexPath.row)
                                        idArray.remove(at: indexPath.row)
                                        self.tableView.reloadData()
                                        
                                        do {
                                            try context.save()
                                            Helper.Alert(title: "Başarılı...", message: "Silme İşlemi Başarılı",hasReturn: false,over:self)

                                            
                                        } catch {
                                            Helper.Alert(title: "Hata...", message: "Silme İşlemi Sırasında Hata",hasReturn: false,over:self)

                                        }
                                        
                                        break
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                    } catch {
                        Helper.Alert(title: "Hata...", message: "Silme İşlemi Sırasında Hata",hasReturn: false,over:self)
                    }
        }
    }
    
    

}
