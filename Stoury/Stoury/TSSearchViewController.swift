//
//  TSFeedViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 10/1/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class TSSearchViewController: UIViewController {
   
    @IBOutlet var tableView: UITableView!
    var searchArray = [TSStoury]()
    
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


extension TSSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
}

extension TSSearchViewController: UITableViewDelegate {
    
}
