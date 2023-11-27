//
//  TaskViewController.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/6/23.
//

import UIKit
import ParseSwift

class TaskViewController: UIViewController, UITableViewDelegate {
        
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var task: Task?
    private var items: [TaskItem] = []
    var tasks: [Task] = []
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
    }
    
    
    private func updateUI() {
        titleLabel.text = task?.title
        
        if let dueDate = task?.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            dueDateLabel.text = formatter.string(from: dueDate)
        } else {
            dueDateLabel.text = "No Due Date"
        }
        
        items = task?.items ?? []
        tableView.reloadData()
        
    }
    
    private func showAlert(error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
    
    @objc private func handleRefresh() {
        queryTasks()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryTasks()
    }
    
    private func queryTasks() {
        let query = Task.query()
            .include("title", "totalPoints")
            .order([.descending("dueDate")])
        
        query.find { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedTasks):
                    self?.tasks = fetchedTasks
                    if let currentTaskId = self?.task?.objectId {
                        self?.task = fetchedTasks.first { $0.objectId == currentTaskId }
                        self?.items = self?.task?.items ?? []
                    }
                    self?.updateUI() 
                case .failure(let error):
                    self?.showAlert(error: error)
                }
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TaskDetailSegue",
           let detailViewController = segue.destination as? TaskDetailViewController,
           let selectedIndexPath = tableView.indexPathForSelectedRow {
            
            guard let taskToPass = task else {
                        print("Task is nil before segue")
                        return
                    }
            
            detailViewController.task = taskToPass
            
            if let selectedTaskItem = task?.items?[selectedIndexPath.row] {
                detailViewController.selectedItem = selectedTaskItem.title
                detailViewController.selectedTitle = task?.title
                detailViewController.selectedDueDate = task?.dueDate
                detailViewController.itemPoints = selectedTaskItem.itemPoints
                detailViewController.isComplete = selectedTaskItem.isComplete
                detailViewController.selectedItemIndex = selectedIndexPath.row

                print("Selected TaskItem: \(selectedTaskItem)")
                print("Selected Item Index: \(selectedIndexPath.row)")
                
            }
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "TaskDetailSegue", sender: indexPath)
    }
}


extension TaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else {
                return UITableViewCell()
            }
            
            let taskItem = items[indexPath.row]
            let currentUser = User.current
        
        cell.configure(with: taskItem, currentUser: currentUser)
            
            return cell
        }
    }

protocol TaskDetailViewControllerDelegate: AnyObject {
    func didUpdateTask(_ task: Task)
}



