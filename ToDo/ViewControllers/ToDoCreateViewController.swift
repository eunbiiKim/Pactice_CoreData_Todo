import UIKit
import CoreData

class ToDoCreateViewController: UIViewController {
    
    var todo: Todo?

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.becomeFirstResponder()
        
        if let todo = todo {
            textView.text = todo.title
            segmentedControl.selectedSegmentIndex = Int(todo.priotity)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        guard let title = textView.text, !title.isEmpty else {
            return
        }

        if let todo = self.todo {
            todo.title = title
            todo.priotity = Int16(segmentedControl.selectedSegmentIndex)
        } else {
            let delegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate
            assert(delegate != nil)
            
            let priority = Int16(self.segmentedControl.selectedSegmentIndex)
            
            delegate.persistentContainer.performBackgroundTask { (context) in
                let todo = Todo(context: context)
                todo.title = title
                todo.priotity = priority
                todo.date = Date()
                
                do {
                    try context.save()
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print("Error saving todo: \(error)")
                }
            }
        }
    }
}

