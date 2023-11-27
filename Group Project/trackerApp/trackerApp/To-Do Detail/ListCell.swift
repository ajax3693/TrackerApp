//
//  ListCell.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/15/23.
//

import UIKit
import Alamofire
import AlamofireImage

class ListCell: UITableViewCell {
    
    @IBOutlet weak var listPoints: UILabel!
    @IBOutlet weak var completedImage: UIImageView!
    @IBOutlet weak var itemsLabel: UILabel!
    
    func configure(with item: TaskItem, currentUser: User?) {
        itemsLabel.text = item.title
        listPoints.text = "\(item.itemPoints)"
        
        let isCompleted = currentUser != nil && item.completedBy.contains(where: { $0.objectId == currentUser?.objectId })
        completedImage.image = UIImage(systemName: isCompleted ? "hurricane.circle.fill" : "circle")?.withRenderingMode(.alwaysTemplate)
        completedImage.tintColor = isCompleted ? .red : .white
        

    }
  }
