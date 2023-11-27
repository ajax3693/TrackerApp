//
//  SignUpViewController.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/2/23.
//

import UIKit
import ParseSwift
import PhotosUI

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()

    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
      
      @IBAction func onSignUpTapped(_ sender: Any) {
          guard let username = usernameField.text,
                let email = emailField.text,
                let password = passwordField.text,
                let confirmPassword = confirmPasswordField.text,
                !username.isEmpty,
                !password.isEmpty,
                !confirmPassword.isEmpty else {
              
              showMissingFieldsAlert()
              return
          }
          
          guard password == confirmPassword else {
              showPasswordMismatchAlert()
              return
          }
          
          var newUser = User()
          newUser.username = username
          newUser.email = email
          newUser.password = password
          
          
          newUser.signup { [weak self] result in
              switch result {
              case .success(let user):
                  print("Successfully signed up user \(user)")
                  NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                  
              case .failure(let error):
                  self?.showAlert(description: error.localizedDescription)
              }
          }
      }
      
      private func showPasswordMismatchAlert() {
          let alertController = UIAlertController(title: "Oops...", message: "Password and Confirm Password must match", preferredStyle: .alert)
          let action = UIAlertAction(title: "OK", style: .default)
          alertController.addAction(action)
          present(alertController, animated: true)
      }
      
      private func showMissingFieldsAlert() {
          let alertController = UIAlertController(title: "Oops...", message: "We need all fields filled out in order to sign you up", preferredStyle: .alert)
          let action = UIAlertAction(title: "OK", style: .default)
          alertController.addAction(action)
          present(alertController, animated: true)
      }
  }

extension SignUpViewController {
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
}
