import Foundation
import CoreData

extension TodoItem {
    static func create(in context: NSManagedObjectContext, title: String, notes: String? = nil, dueDate: Date? = nil, priority: Int16 = 0) -> TodoItem {
        let item = TodoItem(context: context)
        item.title = title
        item.notes = notes
        item.dueDate = dueDate
        item.priority = priority
        item.createdAt = Date()
        item.isCompleted = false
        return item
    }
}
