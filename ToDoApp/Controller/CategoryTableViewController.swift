//
//  CategoryTableViewController.swift
//  ToDoApp
//
//  Created by Nikita on 15/2/23.
//

import UIKit
import CoreData

final class CategoryTableViewController: UITableViewController {
    
    private var categories = [Category]()
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    private let request: NSFetchRequest<Category> = Category.fetchRequest()
    
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
        navigationController?.title = "ToDoApp"
        searchBar.delegate = self
        
        loadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        addAlertController(title: "Add new category",
                           buttonTitle: "Add",
                           placeholderText: "Write new category here")
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
            let newCategory = Category(context: context)
            
            newCategory.name = textField.text
            
            self?.categories.append(newCategory)
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
    private func loadData(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            
            guard let context else { return }
            categories = try context.fetch(request)
        } catch {
            
            print(String(describing: error))
        }
    }
    
    // MARK: - Delegate & DataSource:
    
    // numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    // edit for row
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Delete the row from the data source
            context?.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            saveData()
        }
    }
    
    // titleForDeleteConfirmationButtonForRowAt
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        return "Remove"
    }
    
    // cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCategoriesCell", for: indexPath)
        let category = categories[indexPath.row]
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = category.name
        
        cell.contentConfiguration = configuration
        
        return cell
    }
    
    // didSelectRowAt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        saveData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as? ToDoListTableViewController
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        destinationVC?.selectedCategory = categories[indexPath.row]
    }
}

// MARK: - extensions:


// Search bar delegate
extension CategoryTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text else { return }
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
