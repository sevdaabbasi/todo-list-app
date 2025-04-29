//
//  TodoList.swift
//  Deneme
//
//  Created by Sevda Abbasi on 20.04.2025.
//

import UIKit
import CoreData

class TodoList: UITableViewController {
    
    // MARK: - Properties
    private var items: [TodoItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchItems()
    }
    
    // MARK: - Core Data
    private func fetchItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = TodoItem.fetchRequest()
        
        do {
            items = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    private func saveItem(title: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let item = TodoItem(context: context)
        item.title = title
        item.createdAt = Date()
        
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Failed to save item: \(error)")
        }
    }
    
    private func deleteItem(at index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(items[index])
        
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Yeni Görev", message: "Yeni bir görev ekleyin", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Görev başlığı"
        }
        
        let addAction = UIAlertAction(title: "Ekle", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text,
                  !text.isEmpty else { return }
            
            self?.saveItem(title: text)
        }
        
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TodoList {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteItem(at: indexPath.row)
        }
    }
}

