//
//  viewController+Extension.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/13/23.
//

import Foundation
import UIKit

extension UIViewController {

    func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Unknown error")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
