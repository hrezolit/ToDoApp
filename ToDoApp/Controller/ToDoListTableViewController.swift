//
//  ToDoListTableViewController.swift
//  ToDoApp
//
//  Created by Nikita on 24/12/22.
//

import UIKit
import CoreData

final class ToDoListTableViewController: UITableViewController {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        // Alert controller
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default) { [weak self] action in
            guard let context = self?.context else { return }
            let newItem = Item(context: context)
            newItem.title = textField.text
            newItem.done = false
            self?.itemArray.append(newItem)
            self?.saveItems()
        }
        
        alert.addTextField { alertTF in
            alertTF.placeholder = "Write new item here"
            textField = alertTF
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true)
        
    }
    
    /// Saving data using property list encoder
    private func saveItems() {
        
        do {
            try context?.save()
        } catch {
            print(String(describing: error))
        }
        
        self.tableView.reloadData()
    }
    
    
    // MARK: - numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
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
        
        saveItems()
    }
}
