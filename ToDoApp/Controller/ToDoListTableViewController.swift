//
//  ToDoListTableViewController.swift
//  ToDoApp
//
//  Created by Nikita on 24/12/22.
//

import UIKit

final class ToDoListTableViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem0 = Item()
        newItem0.title = "Buy vegetables"
        itemArray.append(newItem0)
        
        let newItem1 = Item()
        newItem1.title = "Buy Meat"
        itemArray.append(newItem1)
        
        let newItem2 = Item()
        newItem2.title = "Buy Sugar"
        itemArray.append(newItem2)
    }
    
    //MARK: - actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        // Alert controller
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default) { [weak self] action in
            
            guard let text = textField.text else { return }
            let newItem = Item()
            newItem.title = text
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
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            guard let url = dataFilePath else { return }
            try data.write(to: url)
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
