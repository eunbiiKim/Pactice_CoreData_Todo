import UIKit
import CoreData

class ToDoCreateViewController: UIViewController {

    //MARK: CoreData Properties
    var managedContext: NSManagedObjectContext!
    var todo: Todo?

    //MARK: 키보드 이슈 찾아보기
    //MARK: Outlets
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textView.becomeFirstResponder()

        if let todo = todo {
            textView.text = todo.title
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
            let todo = Todo(context: managedContext)
            todo.title = title
            todo.priotity = Int16(segmentedControl.selectedSegmentIndex)
            todo.date = Date()
        }

        do {
            try managedContext.save()
            self.navigationController?.popViewController(animated: true)
            textView.resignFirstResponder()
        } catch {
            print("Error saving todo: \(error)")
        }
    }
}

