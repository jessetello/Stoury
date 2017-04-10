//
//  TSFeedViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 10/1/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
   
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loader: UIActivityIndicatorView!
    
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
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor.lightGray
        self.tableView.register(UINib(nibName: "StouryCell", bundle: nil), forCellReuseIdentifier: "StouryCell")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(HomeViewController.logout))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRecentStourys()
    }
    
    func logout() {
        AuthenticationManager.sharedInstance.logout()
    }
    
    func getRecentStourys() {
        self.loader.hidesWhenStopped = true
        self.loader.startAnimating()
        DataManager.sharedInstance.getRecentPosts { success in
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                if success {
                    self.tableView.reloadData()
                }
            }
        }
    }

}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.sharedInstance.recentPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "StouryCell", for: indexPath) as! StouryCell
        let stoury = DataManager.sharedInstance.recentPosts[indexPath.row]
        cell.title.text = stoury.title
        cell.location.text = stoury.location ?? "Unknown"
        cell.stateOrCountry.text = stoury.stateOrCountry ?? ""
        cell.userName.text = stoury.userName
        
        let minutes = Int(stoury.length ?? 00.00) / 60 % 60
        let seconds = Int(stoury.length ?? 00.00) % 60
        cell.videoLength.text = String(format:"%02i:%02i", minutes, seconds)
        cell.videoImage.image = UIImage(named: "PlaceHolder")
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138.5
    }
}

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

