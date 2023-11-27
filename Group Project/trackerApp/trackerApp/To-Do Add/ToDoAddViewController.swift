import UIKit
import ParseSwift

class ToDoAddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet var itemsFields: [UITextField]!
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet weak var pointValue: UIPickerView!
    
    var pointOptions = [1, 2, 3]
    var selectedPointValue: Int = 1
    
    var onComposeTask: ((Task) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pointValue.dataSource = self
        pointValue.delegate = self
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())

        if let tomorrow = tomorrow {
                dueDatePicker.minimumDate = tomorrow
                dueDatePicker.date = tomorrow 
            }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          return pointOptions.count
      }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return "\(pointOptions[row])"
       }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           selectedPointValue = pointOptions[row]
       }

    
    @IBAction func didTapSaveButton(_ sender: Any) {
        
        let title = titleField.text ?? ""
               let dueDate = (dueDatePicker.date + 1)


        var taskItems: [TaskItem] = []
               for itemField in itemsFields {
                   if let itemText = itemField.text, !itemText.isEmpty {
                       let taskItem = TaskItem(title: itemText, itemPoints: selectedPointValue, isComplete: false, completedBy: [], imageFile: [])
                       taskItems.append(taskItem)
                   }
               }

        let newTask = Task(title: title, items: taskItems, dueDate: dueDate)

            
            newTask.save { result in
                switch result {
                case .success(let savedTask):
                    print("Successfully saved task: \(savedTask)")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                case .failure(let error):
                    print("Error saving task: \(error.localizedDescription)")
                    DispatchQueue.main.async { 
                    }
                }
            }
        }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func presentEmptyFieldsAlert(message: String) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: message,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}
