import Foundation
import CoreData

@objc(TodoItem)
public class TodoItem: NSManagedObject {
    @NSManaged public var title: String?
    @NSManaged public var createdAt: Date?
}

extension TodoItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItem> {
        return NSFetchRequest<TodoItem>(entityName: "TodoItem")
    }
} 