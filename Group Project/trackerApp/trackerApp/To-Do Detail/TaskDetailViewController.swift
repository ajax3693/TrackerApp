//
//  TaskDetailViewController.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/6/23.
//

import UIKit
import PhotosUI
import CoreLocation
import ParseSwift
import Alamofire
import AlamofireImage

class TaskDetailViewController: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: TaskDetailViewControllerDelegate?

    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var attachPhotoButton: UIButton!
    @IBOutlet weak var toDoLabel: UILabel!
    @IBOutlet private weak var completedImageView: UIImageView!
    @IBOutlet private weak var completedLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    private var imageDataRequest: DataRequest?
    
    var selectedItem: String?
    var selectedTitle: String?
    var selectedDueDate: Date?
    var itemPoints: Int?
    var isComplete: Bool = false
    var task: Task?
    var selectedItemIndex: Int?
    
    var currentUser: User?
    var tasks: [Task] = []
    var completedBy: [User] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = User.current,
              let items = task?.items,
              let selectedItemIndex = selectedItemIndex,
              selectedItemIndex < items.count {
               
               let selectedItem = items[selectedItemIndex]
               let userObjectIds = selectedItem.completedBy.map { $0.objectId }
         
               isComplete = userObjectIds.contains(currentUser.objectId)
               if isComplete {
                   attachPhotoButton.isHidden = true
                   takePhotoButton.isHidden = true
                   saveButton.isHidden = true
                   
                  
                   if let imageFile = selectedItem.imageFile.first {
                       imageDataRequest = AF.request(imageFile.url!).responseImage { [weak self] response in
                           switch response.result {
                           case .success(let image):
                               DispatchQueue.main.async {
                                   self?.selectedImageView.image = image
                               }
                           case .failure(let error):
                               print("Error fetching image: \(error.localizedDescription)")
                           }
                       }
                   }
               }
           } else {
               isComplete = false
           }

           updateUI()
       }

    private func updateUI() {
        titleLabel.text = selectedTitle
        dueDateLabel.text = selectedDueDate?.formattedDate() ?? "No Due Date"
        pointsLabel.text = "\(itemPoints ?? 0)"
        toDoLabel.text = selectedItem
        
        let completedImage = isComplete ? "hurricane.circle.fill" : "circle"
        completedImageView.image = UIImage(systemName: completedImage)
        completedLabel.text = isComplete ? "Complete" : "Incomplete"
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let dueDate = selectedDueDate, dueDate < today  {
            let completedImage = isComplete ? "hurricane.circle.fill" : "bolt.slash.circle.fill"
            completedImageView.image = UIImage(systemName: completedImage)
            completedLabel.text = isComplete ? "Completed" : "Missed"
            completedImageView.tintColor = .white
            completedLabel.textColor = .white
            takePhotoButton.isHidden = true
            attachPhotoButton.isHidden = true
            saveButton.isHidden = true
            
            
        }
    }
    
    private func updateUserScore() {
        if var currentUser = User.current {
            let currentScoreInt = Int(currentUser.userScore ?? "") ?? 0
            
            let newScoreInt = currentScoreInt + itemPoints!
            
            currentUser.userScore = String(newScoreInt)
            print("Updated Score: \(currentUser.userScore)")
            
            currentUser.save { saveResult in
                switch saveResult {
                case .success:
                    print("User score updated successfully.")
                    User.current?.fetch { result in
                        switch result {
                        case .success(let refreshedUser):
                            print("Score Update: \(refreshedUser.userScore ?? "0")")
                        case .failure(let error):
                            print("Error fetching user after update: \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error updating user score: \(error)")
                }
            }
        } else {
            print("No current user found")
        }
    }

    
    private func completeTaskItem() {
        if let taskToUpdate = task,
           let selectedItemIndex = selectedItemIndex,
           let currentUser = User.current,
           var task = task,
           let items = task.items,
           selectedItemIndex < items.count,
           let image = selectedImageView.image,
           
           let imageData = image.jpegData(compressionQuality: 0.1) {
            
            var itemToUpdate = items[selectedItemIndex]
            if !itemToUpdate.completedBy.contains(where: { $0.objectId == currentUser.objectId }) {
                itemToUpdate.completedBy.append(currentUser)
                itemToUpdate.isComplete = true
                
                let imageName = "task_item_image_\(itemToUpdate.title).jpg"
                let file = ParseFile(name: imageName, data: imageData)
                
                file.save { [weak self] result in
                    switch result {
                    case .success(let savedFile):
                        itemToUpdate.imageFile = [savedFile]
                        task.items?[selectedItemIndex] = itemToUpdate
                        task.save { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    self?.task = task
                                    self?.isComplete = true
                                    self?.updateUI()
                                    print("Task item updated successfully.")
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    print("Error updating task item for currentUser: \(error)")
                                }
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            print("Error saving image file: \(error)")
                        }
                    }
                }
            }
            delegate?.didUpdateTask(taskToUpdate)
        }
    }


    
    @IBAction func markAsCompleteTapped(_ sender: Any) {
        completeTaskItem()
        if takePhotoButton.isHidden == true {
            updateUserScore()
        }
        self.navigationController?.popViewController(animated: true)
    }

    
    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self?.presentImagePicker()
                }
            default:
                DispatchQueue.main.async {
                    self?.presentGoToSettingsAlert()
                }
            }
            }
        }
        else {
            presentImagePicker()
            
        }
        
    }
    
    @IBAction func didTapTakePhotoButton(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = .camera
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    private func presentImagePicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        
        config.filter = .images
        
        config.preferredAssetRepresentationMode = .current
        
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        processPickedImage(results: results)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            print("Unable to get image")
            return
        }
        picker.dismiss(animated: true)
        selectedImageView.image = image
        self.attachPhotoButton.isHidden = true
        self.takePhotoButton.isHidden = true
        updateUI()
        
    }
    
    private func processPickedImage(results: [PHPickerResult]) {
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] imageObject, error in
            DispatchQueue.main.async {
                if let image = imageObject as? UIImage {
                    self?.selectedImageView.image = image
                    self?.updateUI()
                    self?.attachPhotoButton.isHidden = true
                    self?.takePhotoButton.isHidden = true
                }
            }
        }
    }
}
    
extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
    
extension TaskDetailViewController {
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController(
            title: "Camera Access Required",
            message: "In order to post a photo to complete a task, we need access to your camera. You can allow access in Settings",
            preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
}


extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.objectId == rhs.objectId
    }
}




