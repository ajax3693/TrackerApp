//
//  ScoresViewController.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/6/23.
//

import UIKit
import ParseSwift
import SwiftUI

class ScoresViewController: UIViewController, UICollectionViewDataSource {
    
    var users: [User] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        loadUserData()
                
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let numberOfColumns: CGFloat = 3
        
        _ = (collectionView.bounds.width - layout.minimumInteritemSpacing * (numberOfColumns - 1)) / numberOfColumns
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            refreshUserData()
        }
    
    private func refreshUserData() {
          loadUserData()
      }
    
    private func loadUserData() {
        let query = User.query()
        query.find { [weak self] result in
            switch result {
            case .success(let fetchedUsers):
                DispatchQueue.main.async {
                    self?.users = fetchedUsers
                }
            case .failure(let error):
                print("Error fetching users: \(error.localizedDescription)")
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScoresCell", for: indexPath) as? ScoresCell else {
            fatalError("Could not dequeue ScoresCell")
        }
        
        let sortedUsers = users.sorted { ($0.userScore ?? "0") > ($1.userScore ?? "0") }
        let user = sortedUsers[indexPath.item]
        print(sortedUsers)
        
        cell.configure(with: user, rank: indexPath.item + 1)
        
        return cell
    }
}

 
