//
//  TSFeedViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 10/1/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class TSHomeViewController: UIViewController {
   
    @IBOutlet var tableView: UITableView!
    var searchArray = [TSStoury]()
    let homeList = ["Near Me","Hotels","Restaurants","Vacation Rentals"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}


extension TSHomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = homeList[indexPath.item]
        return cell
    }
}

extension TSHomeViewController: UITableViewDelegate {
    
}
