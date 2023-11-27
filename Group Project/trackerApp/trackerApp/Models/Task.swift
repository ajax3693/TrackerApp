//
//  Task.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/6/23.
//

import Foundation
import ParseSwift
import UIKit

struct TaskItem: Codable {
    var title: String
    var itemPoints: Int
    var isComplete: Bool
    var completedBy: [User]
    var imageFile: [ParseFile]

}

struct Task: ParseObject {
    static var className: String {
        return "Task"
    }
    
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    var user: User?
    
    var title: String?
    var taskListId: String?
    var items: [TaskItem]?
    var dueDate: Date?
    var totalPoints: Int? {
        return items?.reduce(0) { $0 + $1.itemPoints }
    }
    var image: ParseFile?
    var completed: Bool?
    var isComplete: Bool {
        get {
            return items?.allSatisfy { $0.isComplete } ?? false
        }
        set {
            if newValue {
                if var items = items {
                    for index in items.indices {
                        items[index].isComplete = true
                    }
                    self.items = items
                }
            }
        }
    }
    

    mutating func updateItem(at index: Int, with item: TaskItem, completion: @escaping (Result<Bool, ParseError>) -> Void) {
        guard let itemsArray = items, index < itemsArray.count else {
            completion(.failure(ParseError(code: .objectNotFound, message: "Invalid index")))
            return
        }
        
        items?[index] = item

        save { result in
            switch result {
            case .success:
                print("Task item updated successfully for currentUser.")
                completion(.success(true))
            case .failure(let error):
                print("Error updating task item for currentUser: \(error)")
                completion(.failure(error))
            }
        }
    }


    
    mutating func updateItemWithImage(at index: Int, image: UIImage, completion: @escaping (Result<Bool, ParseError>) -> Void) {
            guard var itemsArray = items, index < itemsArray.count else {
                completion(.failure(ParseError(code: .objectNotFound, message: "Invalid index")))
                return
            }

            guard let imageData = image.jpegData(compressionQuality: 0.1) else {
                completion(.failure(ParseError(code: .unknownError, message: "Failed to process image data")))
                return
            }

            let file = ParseFile(name: "task_item_image.jpg", data: imageData)
            itemsArray[index].imageFile = [file]
            items = itemsArray

            save { result in
                switch result {
                case .success:
                    print("Task item with image updated successfully.")
                    completion(.success(true))
                case .failure(let error):
                    print("Error updating task item with image: \(error)")
                    completion(.failure(error))
                }
            }
        }
    
    mutating func setPointsPerItem() {
        guard let totalPoints = totalPoints, let itemCount = items?.count, itemCount > 0 else { return }
        
        let pointsPerItem = totalPoints / itemCount
        if var items = items {
            for index in items.indices {
                items[index].itemPoints = pointsPerItem
            }
            self.items = items
        }
    }
}
    
    var isSharedWithCurrentUser: Bool {
        return true
}

extension Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.objectId == rhs.objectId
    }
}


extension TaskItem {
    func setImage(from image: UIImage, completion: @escaping (Result<[ParseFile], ParseError>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            completion(.failure(ParseError(code: .unknownError, message: "Failed to process image data")))
            return
        }

        let file = ParseFile(name: "task_image.jpg", data: imageData)
        file.save { result in
            switch result {
            case .success(let savedFile):
                completion(.success([savedFile]))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


