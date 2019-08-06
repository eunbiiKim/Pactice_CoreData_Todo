
import UIKit
import CoreData

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Outlet
    @IBOutlet weak var todoListTableView: UITableView!

    // MARK: - CoreData Properties
    var resultController: NSFetchedResultsController<Todo>!
    let coreDataStack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 테이블뷰의 프로토콜 위임자 설정
        self.todoListTableView.delegate = self
        self.todoListTableView.dataSource = self

        // Request
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)

        // Initialize resultController
        request.sortDescriptors = [sortDescriptors]
        self.resultController = NSFetchedResultsController(fetchRequest: request,
                                                      managedObjectContext: coreDataStack.managedContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil
        )

        self.resultController.delegate = self

        // Fetch
        do {
            try resultController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.todoListTableView.reloadData()
    }


    // MARK: - TableViewDataSource's methods implement
    // 테이블뷰의 셀 등록과 셀 속성 정의
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
            // TODO: Delete todo
            let todo = self.resultController.object(at: indexPath)
            self.resultController.managedObjectContext.delete(todo)
            do {
                try self.resultController.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed: \(error)")
                completion(false)
            }

        }
        action.title = "Delete"
        action.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .destructive, title: "Done") { (action, view, completion) in
            // TODO: Done todo
            let todo = self.resultController.object(at: indexPath)
            self.resultController.managedObjectContext.delete(todo)
            do {
                try self.resultController.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed: \(error)")
                completion(false)
            }

        }

        action.title = "Done"
        action.backgroundColor = .green

        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showAddTodo", sender: todoListTableView.cellForRow(at: indexPath))
    }


    // MARK: - Navigaiton
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? ToDoCreateViewController {
            vc.managedContext = resultController.managedObjectContext
        }

        if let cell = sender as? UITableViewCell, let vc = segue.destination as? ToDoCreateViewController {
            vc.managedContext = resultController.managedObjectContext
            if let indexPath = todoListTableView.indexPath(for: cell) {
                let todo = resultController.object(at: indexPath)
                vc.todo = todo
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
