//
//  TaskCell.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/13/23.
//

import UIKit
import Alamofire
import AlamofireImage

class TaskCell: UITableViewCell {
    
  
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var listPoints: UILabel!
    @IBOutlet weak var completedImage: UIImageView!
    
    func configure(with task: Task, currentUser: User?) {
        taskName.text = task.title
        if let totalPoints = task.totalPoints {
            listPoints.text = "\(totalPoints)"
        } else {
            listPoints.text = "N/A"
        }
        
        if let currentUserObjectId = currentUser?.objectId, let items = task.items {
            let allCompletedByCurrentUser = items.allSatisfy { taskItem in
                taskItem.completedBy.contains(where: { user in user.objectId == currentUserObjectId })
            }
            completedImage.image = UIImage(systemName: allCompletedByCurrentUser ? "hurricane.circle.fill" : "circle")?.withRenderingMode(.alwaysTemplate)
            completedImage.tintColor = allCompletedByCurrentUser ? .red : .white
//        } else {
//            completedImage.image = UIImage(systemName: "bolt.slash.circle.fill")?.withRenderingMode(.alwaysTemplate)
//            completedImage.tintColor = .white
        }
    }
}

