//
//  ToDoListTableViewController.swift
//  ToDoApp
//
//  Created by Nikita on 24/12/22.
//

import UIKit
import CoreData

final class ToDoListTableViewController: UITableViewController {
    
    private var itemArray = [Item]()
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Data base file path
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist") as Any)
        
        loadData()
    }
    
    //MARK: - actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        addAlertController(title: "Add new item", buttonTitle: "Add", placeholderText: "Write new item here")
    }
    
    /// Creat alert controller
    /// - Parameters:
    ///   - title: title for alert controller
    ///   - buttonTitle: tittle for button
    ///   - placeholderText: text for placeholder
    private func addAlertController(title: String, buttonTitle: String, placeholderText: String) {
        var textField = UITextField()
        
        // Alert controller
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: buttonTitle, style: .default) { [weak self] action in
            
            // Add data for saving
            guard let context = self?.context else { return }
            let newItem = Item(context: context)
            
            newItem.title = textField.text
            newItem.done = false
            
            self?.itemArray.append(newItem)
            self?.saveData()
        }
        
        alert.addTextField { alertTF in
            alertTF.placeholder = placeholderText
            textField = alertTF
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Methods for Core Data manipulations:
    
    /// Saving data
    private func saveData() {
        
        do {
            try context?.save()
        } catch {
            print(String(describing: error))
        }
        self.tableView.reloadData()
    }
    
    /// Loading data
    private func loadData() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            guard let context else { return }
            itemArray = try context.fetch(request)
        } catch {
            print(String(describing: error))
        }
    }
    
    // MARK: - numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // MARK: - edit for row
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            context?.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - titleForDeleteConfirmationButtonForRowAt
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    // MARK: - cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        configuration.text = item.title
        
        cell.contentConfiguration = configuration
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        return cell
    }
    
    // MARK: - didSelectRowAt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        saveData()
    }
}
