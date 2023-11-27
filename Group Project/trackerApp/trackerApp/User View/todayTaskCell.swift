//
//  todayTaskCell.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/15/23.
//

import UIKit
import Alamofire
import AlamofireImage

class todayTaskCell: UITableViewCell {
    
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    func configure(with task: Task, currentUser: User?) {
        todoLabel.text = task.title
        if let dueDate = task.dueDate, Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0 > 3 {
                    completedImageView.isHidden = true
                    pointsLabel.isHidden = true
        } else {
            completedImageView.isHidden = false
            pointsLabel.isHidden = false
            
            if let totalPoints = task.totalPoints {
                pointsLabel.text = "\(totalPoints)"
            } else {
                pointsLabel.text = "N/A"
            }
        }
        
        if let currentUserObjectId = currentUser?.objectId, let items = task.items {
            let allCompletedByCurrentUser = items.allSatisfy { taskItem in
                taskItem.completedBy.contains(where: { user in user.objectId == currentUserObjectId })
            }
            completedImageView.image = UIImage(systemName: allCompletedByCurrentUser ? "hurricane.circle.fill" : "circle")?.withRenderingMode(.alwaysTemplate)
            completedImageView.tintColor = allCompletedByCurrentUser ? .red : .white
        } else {
            completedImageView.image = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
            completedImageView.tintColor = .black
        }
    }
}

