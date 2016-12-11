//
//  TSFeedViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 10/1/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class TSFeedViewController: UIViewController {
   
    @IBOutlet var tableView: UITableView!
    var feedArray = [TSStoury]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.sharedInstance.getUserFeed {[weak self] (success, posts) in
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}


extension TSFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedArray.count
    }
    
}

extension TSFeedViewController: UITableViewDelegate {
    
    
    
}
