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
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchItems()
    }
    

    
    // MARK: - Core Data
    private func fetchItems() {
        let fetchRequest = TodoItem.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "priority", ascending: false),
            NSSortDescriptor(key: "dueDate", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        do {
            items = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        performSegue(withIdentifier: "ShowTodoDetail", sender: nil)
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTodoDetail" {
            let detailVC = segue.destination as! TodoDetailViewController
            detailVC.delegate = self
            
            if let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell) {
                detailVC.item = items[indexPath.row]
            }
        }
    }
    
    private func toggleCompletion(for item: TodoItem) {
        item.isCompleted.toggle()
        saveContext()
    }
    
    private func deleteItem(_ item: TodoItem) {
        context.delete(item)
        saveContext()
    }
}

// MARK: - UITableViewDataSource
extension TodoList {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        
        if item.isCompleted {
           /* content.textProperties.strikethroughStyle = .single*/
            content.textProperties.color = .systemGray
        }
        
        if let dueDate = item.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            content.secondaryText = formatter.string(from: dueDate)
        } else if let notes = item.notes, !notes.isEmpty {
            content.secondaryText = notes
        }
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowTodoDetail", sender: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Silme ve tamamlama
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = items[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            self?.deleteItem(item)
            completion(true)
        }
        
        let completeAction = UIContextualAction(style: .normal, title: item.isCompleted ? "Geri Al" : "Tamamla") { [weak self] _, _, completion in
            self?.toggleCompletion(for: item)
            completion(true)
        }
        completeAction.backgroundColor = item.isCompleted ? UIColor.systemOrange : UIColor.systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
    }
}

// MARK: - TodoDetailViewControllerDelegate
extension TodoList: TodoDetailViewControllerDelegate {
    func todoDetailViewController(_ controller: TodoDetailViewController, didFinishEditing item: TodoItem) {
        saveContext()
    }
    
    func todoDetailViewController(_ controller: TodoDetailViewController, didFinishAdding item: TodoItem) {
        items.append(item)
        saveContext()
    }
}



/*
 
 import UIKit
 import CoreData

 class TodoList: UITableViewController {
     
     // MARK: - Properties
     private var items: [TodoItem] = []
     
     // CoreData context'i tek noktadan erişilebilir hale getiriyoruz
     private var context: NSManagedObjectContext? {
         let appDelegate = UIApplication.shared.delegate as? AppDelegate
         return appDelegate?.persistentContainer.viewContext
     }
     
     // MARK: - Lifecycle
     override func viewDidLoad() {
         super.viewDidLoad()
         fetchItems()
     }
     
     // MARK: - Core Data
     private func fetchItems() {
         guard let context = context else { return }
         
         let fetchRequest = TodoItem.fetchRequest()
         
         do {
             items = try context.fetch(fetchRequest)
             tableView.reloadData()
         } catch {
             print("Failed to fetch items: \(error)")
         }
     }
     
     private func saveItem(title: String) {
         guard let context = context else { return }
         
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
         guard let context = context else { return }
         
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


*/
