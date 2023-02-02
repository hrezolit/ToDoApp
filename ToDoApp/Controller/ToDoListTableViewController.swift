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
    private let request: NSFetchRequest<Item> = Item.fetchRequest()
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Search..."
        searchBar.sizeToFit()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
    }()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add search bar
        navigationItem.titleView = searchBar
        navigationItem.titleView?.isHidden = false
        
        searchBar.delegate = self
        
        loadData()
    }
    
    //MARK: - actions:
    
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
    
    // MARK: - Constraints:
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            
            searchBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
    private func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest()) {

        do {
            guard let context else { return }
            itemArray = try context.fetch(request)
        } catch {
            print(String(describing: error))
        }
    }
    
    // MARK: - Delegate & DataSource:
    
    // numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // edit for row
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
    
    // titleForDeleteConfirmationButtonForRowAt
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    // cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        configuration.text = item.title
        
        cell.contentConfiguration = configuration
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        return cell
    }
    
    // didSelectRowAt
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

extension ToDoListTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
         
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadData(with: request)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            tableView.reloadData()
        }
    }
}
