//
//  UserViewController.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/6/23.
//

import UIKit
import ParseSwift

class UserViewController: UIViewController,  UIImagePickerControllerDelegate,   UNUserNotificationCenterDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    
    var tasks: [Task] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let refreshControl = UIRefreshControl()
    
    var selectedImage: UIImage?
    
    func updateDateLabels() {
        let currentDate = Date()
        let dayFormatter = DateFormatter()
        let monthFormatter = DateFormatter()

        dayFormatter.dateFormat = "d"
        monthFormatter.dateFormat = "MMMM"

        dayLabel.text = dayFormatter.string(from: currentDate)
        monthLabel.text = monthFormatter.string(from: currentDate)
    }

        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        updateDateLabels()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        setupNotification()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        userImage.addGestureRecognizer(tapGesture)
        userImage.isUserInteractionEnabled = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        
    }
    
    @objc private func handleRefresh() {
        queryTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserScore()
        updateDateLabels()
        queryTasks()
        loadUserData()
        
    }
    
    private func fetchUserScore() {
        User.current?.fetch { [weak self] result in
            switch result {
            case .success(let updatedUser):
                DispatchQueue.main.async {
                    self?.scoreLabel.text = updatedUser.userScore
                }
            case .failure(let error):
                print("Error fetching updated user score: \(error.localizedDescription)")
            }
        }
    }

    
    private func queryTasks() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let threeDaysFromNow = calendar.date(byAdding: .day, value: 3, to: today)!

        let query = Task.query()
            .include("title", "isCompleted", "totalPoints")
            .where("dueDate" >= today)
            .where("dueDate" < threeDaysFromNow)
            .order([.ascending("dueDate")])
        
        query.find { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.tasks = tasks
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
    
    @objc func handleImageTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userImage.image = pickedImage
            userImage.layer.cornerRadius = self.userImage.frame.width / 2
            userImage.clipsToBounds = true
            selectedImage = pickedImage
            uploadImage(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let imageFile = ParseFile(name: "userImage.jpg", data: imageData)
        imageFile.save { result in
            switch result {
            case .success:
                guard var currentUser = User.current else { return }
                currentUser.userImage = imageFile
                currentUser.save { saveResult in
                    switch saveResult {
                    case .success:
                        print("User image successfully updated.")
                    case .failure(let error):
                        print("Error saving user image: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error uploading image file: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func loadUserData() {
        guard let currentUser = User.current else { return }
        
        usernameLabel.text = currentUser.username
        scoreLabel.text = currentUser.userScore
        print(currentUser.userScore)
        
        if let userImageFile = currentUser.userImage {
            userImageFile.fetch { result in
                switch result {
                case .success(let file):
                    if let url = file.localURL, let data = try? Data(contentsOf: url) {
                        let image = UIImage(data: data)
                        DispatchQueue.main.async {
                            self.userImage.image = image
                            self.userImage.layer.cornerRadius = self.userImage.frame.width / 2
                            self.userImage.clipsToBounds = true
                            
                        }
                    }
                case .failure(let error):
                    print("Error downloading image file: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.userImage.image = UIImage(named: "person.crop.circle.fill")
                        self.userImage.layer.cornerRadius = self.userImage.frame.width / 2
                        self.userImage.clipsToBounds = true
                    }
                }
            }
        }
    }
    
    private func loadUserTasks() {
        let query = Task.query
        query.find { results in
            switch results {
            case .success(let tasks):
                self.tasks = tasks
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching tasks: \(error)")
            }
        }
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
    
    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TaskSegue" {
            if segue.identifier == "TaskSegue",
               let taskViewController = segue.destination as? TaskViewController,
               let indexPath = tableView.indexPathForSelectedRow {
                let selectedTask = tasks[indexPath.row]
                taskViewController.task = selectedTask
            }
        }
    }
}
    
extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.isEmpty ? 1 : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tasks.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "todayTaskCell", for: indexPath) as? todayTaskCell else {
                return UITableViewCell()
            }
            cell.todoLabel.text = "You've completed all your tasks for the day"
        
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "todayTaskCell", for: indexPath) as? todayTaskCell else {
                return UITableViewCell()
            }
            
            let task = tasks[indexPath.row]
            cell.configure(with: task, currentUser: User.current)
            return cell
        }
    }
}

private func setupNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Reminder"
    content.body = "Don't forget to check your tasks for the day!"
    
    var dateComponents = DateComponents()
        dateComponents.hour = 11

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }

