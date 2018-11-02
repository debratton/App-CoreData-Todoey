//
//  CategoriesTVC.swift
//  Todoey
//
//  Created by David E Bratton on 11/1/18.
//  Copyright © 2018 David Bratton. All rights reserved.
//

import UIKit
import CoreData

class CategoriesTVC: UITableViewController {

    var categoriesArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categoriesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        cell.textLabel?.text = categoriesArray[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = categoriesArray[indexPath.row]
            context.delete(itemToDelete)
            saveItems()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemsTVC
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoriesArray[indexPath.row]
        }
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error Saving Context: \(error.localizedDescription)")
        }
        loadItems()
    }
    
    func loadItems(request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoriesArray = try context.fetch(request)
        } catch {
            print("Error Fetching Data: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func presentAlert(alert:String) {
        let alertVC = UIAlertController(title: "Error", message: alert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }

    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if textField.text != "" {
                let newCategory = Category(context: self.context)
                if let newItem = textField.text {
                    newCategory.name = newItem
                    self.categoriesArray.append(newCategory)
                    self.saveItems()
                }
            } else {
                self.presentAlert(alert: "You cannot add a blank category!")
            }
            
            
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
}

extension CategoriesTVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        if let searchText = searchBar.text {
            request.predicate = NSPredicate(format: "name CONTAINS %@", searchText)
            request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true)]
            loadItems(request: request)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchString = searchBar.text {
            if searchString.count == 0 {
                loadItems()
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            } else {
                let request: NSFetchRequest<Category> = Category.fetchRequest()
                request.predicate = NSPredicate(format: "name CONTAINS %@", searchText)
                request.sortDescriptors  = [NSSortDescriptor(key: "name", ascending: true)]
                loadItems(request: request)
            }
        }
    }
}
