//
//  ToDoViewController.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/6/23.
//

import UIKit
import ParseSwift
import PhotosUI


class ToDoViewController: UIViewController, UNUserNotificationCenterDelegate, UITableViewDelegate {
    
    @IBOutlet weak var sortList: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var tasks = [Task]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var currentTasks = [Task]()
    private var allPreviousTasks = [Task]()
    
    private let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        setupNotification()
        
        sortList.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)

        
    }
    
    @objc private func segmentedControlValueChanged() {
            let selectedIndex = sortList.selectedSegmentIndex
            
            switch selectedIndex {
            case 0:
                tasks = currentTasks
            case 1:
                tasks = allPreviousTasks
            default:
                break
            }
            
            tableView.reloadData()
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComposeSegue" {
            if let composeNavController = segue.destination as? UINavigationController,
               let composeViewController = composeNavController.topViewController as? ToDoAddViewController {
                composeViewController.onComposeTask = { [weak self] task in
                    self?.tasks.append(task)
                }
            }
        } else if segue.identifier == "TaskSegue" {
            if segue.identifier == "TaskSegue",
               let taskViewController = segue.destination as? TaskViewController,
               let indexPath = tableView.indexPathForSelectedRow {
                let selectedTask = tasks[indexPath.row]
                taskViewController.task = selectedTask
            }
        }
    }
    
    func handleTaskCompletion(task: Task) {
         tasks = tasks.filter { $0 != task }
         tableView.reloadData()
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
            .order([.ascending("dueDate")])
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        query.find { [weak self] result in
                   switch result {
                   case .success(let tasks):
                       self?.currentTasks = tasks.filter { $0.dueDate ?? Date() >= today
                       }
                       self?.allPreviousTasks = tasks.filter { $0.dueDate ?? Date() < today
                       }
                       self?.sortList.isEnabled = true
                       self?.segmentedControlValueChanged()
                   case .failure(let error):
                       self?.showAlert(error: error)
                   }
                   self?.refreshControl.endRefreshing()
               }
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
    
    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}


extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        
        let task = tasks[indexPath.row]
        cell.configure(with: task, currentUser: User.current)
      
        return cell
    }
}
    
private func setupNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Reminder"
    content.body = "Don't forget to check your tasks for the day!"
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: true)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
    
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { error in
        if let error = error {
            print("Error \(error.localizedDescription)")
        }
    }
}

    
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.sound, .badge, .banner])
}






