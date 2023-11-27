//
//  ScoresCell.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/20/23.
//

import UIKit
import ParseSwift

class ScoresCell: UICollectionViewCell {
    
    @IBOutlet weak var userScore: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userRanking: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    
    func configure(with user: User, rank: Int) {
        userName.text = user.username
        userRanking.text = "#\(rank)"
        userScore.text = user.userScore
        
        let defaultImage = UIImage(systemName: "person.crop.circle.fill") ?? UIImage()
        userImage.image = defaultImage
        
        if let userImageFile = user.userImage, let url = userImageFile.url {
            loadUserImage(from: url)
        }
    }
    
    private func loadUserImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.userImage.image = image
                    self.userImage.layer.cornerRadius = self.userImage.frame.height / 2
                    self.userImage.clipsToBounds = true
                }
            }
        }.resume()
    }
}
