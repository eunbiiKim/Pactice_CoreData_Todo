
import UIKit
import CoreData

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Outlet
    @IBOutlet weak var todoListTableView: UITableView!

    // MARK: - CoreData Properties
    var resultController: NSFetchedResultsController<Todo>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 테이블뷰의 프로토콜 위임자 설정
        self.todoListTableView.delegate = self
        self.todoListTableView.dataSource = self
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let request: NSFetchRequest = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        let delegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate
        assert(delegate != nil)
        
        request.sortDescriptors = [sortDescriptors]
        self.resultController = NSFetchedResultsController(fetchRequest: request,
                                                      managedObjectContext: delegate.persistentContainer.viewContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        self.resultController.delegate = self

        do {
            try resultController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: nil, queue: nil) { (notification) in
            
            delegate.persistentContainer.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = todoListTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell
        let todo = resultController.object(at: indexPath)
        cell.textLabel?.text = todo.title

        return cell
    }

    // MARK: - TableViewDelegate's methods implement
    // todo의 'delete', 'done' 이벤트 구현

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let todo = self.resultController.object(at: indexPath)
            
            let delegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate
            assert(delegate != nil)
            
            delegate.persistentContainer.performBackgroundTask { (context) in
                context.delete(todo)
                
                do {
                    try context.save()
                    completion(true)
                } catch {
                    print("delete failed: \(error)")
                    completion(false)
                }
            }
        }
        
        action.title = "Delete"

        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .destructive, title: "Done") { (action, view, completion) in
            let todo = self.resultController.object(at: indexPath)
            
            let delegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate
            assert(delegate != nil)
            
            delegate.persistentContainer.performBackgroundTask { (context) in
                context.delete(todo)
                
                do {
                    try context.save()
                    completion(true)
                } catch {
                    print("delete failed: \(error)")
                    completion(false)
                }
            }
        }

        action.title = "Done"
        action.backgroundColor = .green

        return UISwipeActionsConfiguration(actions: [action])
    }

    // MARK: - Navigaiton
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ToDoCreateViewController {
            if let indexPath = todoListTableView.indexPathForSelectedRow {
                vc.todo = resultController.object(at: indexPath)
            }
        }
    }

}


extension ToDoListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        todoListTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        todoListTableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                todoListTableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                todoListTableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = todoListTableView.cellForRow(at: indexPath) {
                let todo = resultController.object(at: indexPath)
                cell.textLabel?.text = todo.title
            }
        default:
            break
        }
    }
}
