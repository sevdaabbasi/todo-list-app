import UIKit
import CoreData

protocol TodoDetailViewControllerDelegate: AnyObject {
    func todoDetailViewController(_ controller: TodoDetailViewController, didFinishEditing item: TodoItem)
    func todoDetailViewController(_ controller: TodoDetailViewController, didFinishAdding item: TodoItem)
}

class TodoDetailViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: TodoDetailViewControllerDelegate?
    var item: TodoItem?
    private var isNewItem: Bool { item == nil }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var notesTextView: UITextView!
    @IBOutlet private weak var dueDatePicker: UIDatePicker!
    @IBOutlet private weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet private weak var completedSwitch: UISwitch!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        loadItemData()
    }
    
    // MARK: - Setup
    private func configureNavigationBar() {
        title = isNewItem ? "Yeni Görev" : "Görevi Düzenle"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveButtonTapped)
        )
    }
    
    // MARK: - Actions
    @IBAction private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "Lütfen bir başlık girin")
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if isNewItem {
            let newItem = TodoItem.create(
                in: context,
                title: title,
                notes: notesTextView.text,
                dueDate: dueDatePicker.date,
                priority: Int16(prioritySegmentedControl.selectedSegmentIndex)
            )
            delegate?.todoDetailViewController(self, didFinishAdding: newItem)
        } else {
            item?.title = title
            item?.notes = notesTextView.text
            item?.dueDate = dueDatePicker.date
            item?.priority = Int16(prioritySegmentedControl.selectedSegmentIndex)
            item?.isCompleted = completedSwitch.isOn
            
            delegate?.todoDetailViewController(self, didFinishEditing: item!)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func completedSwitchChanged(_ sender: UISwitch) {
        item?.isCompleted = sender.isOn
    }
    
    // MARK: - Helpers
    private func loadItemData() {
        guard let item = item else { return }
        
        titleTextField.text = item.title
        notesTextView.text = item.notes
        if let dueDate = item.dueDate {
            dueDatePicker.date = dueDate
        }
        prioritySegmentedControl.selectedSegmentIndex = Int(item.priority)
        completedSwitch.isOn = item.isCompleted
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Hata",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
} 