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
    
    var recentStourys = [Stoury]()
    let homeList = ["Restaurants","Bars","Hotels", "Nightlife", "Coffee & Tea"]
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.sharedInstance.getLocation()
        self.navigationController?.navigationBar.topItem?.title = "Stoury"
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.isOpaque = false
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.barTintColor = UIColor.init(red: 4.0, green: 57.0, blue: 94.0, alpha: 1.0)
        searchController.searchBar.setTextColor(color: UIColor.black)

        self.tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.lightGray
        tableView.register(UINib(nibName: "StouryCell", bundle: nil), forCellReuseIdentifier: "StouryCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func getRecentStourys() {
        
        
        
    }

}

extension TSHomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

