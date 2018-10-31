//
//  MainTVC.swift
//  Todoey
//
//  Created by David E Bratton on 10/30/18.
//  Copyright © 2018 David Bratton. All rights reserved.
//

import UIKit
import CoreData

class MainTVC: UITableViewController {

    var itemsArray = [ToDo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        loadItems()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        // HAVE TO CHANGE THIS ONCE YOU USE CLASS MODEL
        //cell.textLabel?.text = itemsArray[indexPath.row]
        cell.textLabel?.text = itemsArray[indexPath.row].title
        
        if itemsArray[indexPath.row].done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
            
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // PRINT ARRAY NUMBER
        print(indexPath.row)
        // PRINT ARRAY VALUE
        print(itemsArray[indexPath.row])
        // IF STATEMENT TO SET CHECKMARK ON SELECTED ROW
        
        if itemsArray[indexPath.row].done == false {
            itemsArray[indexPath.row].done = true
        } else {
            itemsArray[indexPath.row].done = false
        }
        saveItems()

        // MAKE ROW GO BACK TO WHITE AFTER CLICKED INSTEAD OF STAYING GREY
        tableView.deselectRow(at: indexPath, animated: true
            
        )
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = itemsArray[indexPath.row]
            context.delete(itemToDelete)
            saveItems()
        }
    }
   
    @IBAction func addToDoBtnPressed(_ sender: UIBarButtonItem) {
        // HAVE TO DECLARE VARIABLE TO HOLD THE TEXT FIELD
        var textField = UITextField()
        // BUILD ALERT
        let alert = UIAlertController(title: "Add New ToDoey", message: "", preferredStyle: .alert)
        // ADD TITLE AND THIS IS WHERE YOU HAVE TO ADD PRINT AND APPEND TO ARRAY
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newToDo = ToDo(context: self.context)
            if let newItem = textField.text {
                newToDo.title = newItem
                newToDo.done = false
                self.itemsArray.append(newToDo)
                self.saveItems()
            }
        }
        // ADD TEXT BOX
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error Saving Context: \(error.localizedDescription)")
        }
        //let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        loadItems()
    }
    
//    func loadItems() {
//        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
//        do {
//            itemsArray = try context.fetch(request)
//        } catch {
//            print("Error Fetching Data: \(error.localizedDescription)")
//        }
//        tableView.reloadData()
//    }
    // REFACTOR TO ALL CALLS FROM MULTIPLE PLACES
    //func loadItems(request: NSFetchRequest<ToDo>)
    func loadItems(request: NSFetchRequest<ToDo> = ToDo.fetchRequest()) {
        //let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("Error Fetching Data: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search Bar Methods
// WE CAN EITHER DO THIS OR JUST ADD UISearchBarDelegate to top and
// ADD FUNCTION INSIDE THE MainTVC Class
extension MainTVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        // Optional text
        //print(searchBar.text)
        if let searchText = searchBar.text {
            // ORIGINAL BEFORE COMBINING
            //let predicate = NSPredicate(format: "title CONTAINS %@", searchText)
            //request.predicate = predicate
            //let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            // request.sortDescriptors = [sortDescriptor]  HAVE TO PUT IN ARRAY
            request.predicate = NSPredicate(format: "title CONTAINS %@", searchText)
            //HAVE TO ADD TO ARRAY AFTER REFACTORING
            request.sortDescriptors  = [NSSortDescriptor(key: "title", ascending: true)]

//            do {
//                itemsArray = try context.fetch(request)
//            } catch {
//                print("Error Fetching Data: \(error.localizedDescription)")
//            }
            // REFACTOR ABOVE
            loadItems(request: request)
            
        }
    }
    // THIS FUNCTION WILL SEARCH FOR EACH KEY STROKE AND IF BLANK GO BACK TO ALL
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchString = searchBar.text {
            if searchString.count == 0 {
                loadItems()
                // DISPATCH HAS TO BE INSIDE IF OR IT DISMISSES ON EACH KEY STROKE
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            } else {
                let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
                request.predicate = NSPredicate(format: "title CONTAINS %@", searchText)
                request.sortDescriptors  = [NSSortDescriptor(key: "title", ascending: true)]
                loadItems(request: request)
            }
        }
    }
}
