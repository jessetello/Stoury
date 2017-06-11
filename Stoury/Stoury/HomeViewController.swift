//
//  TSFeedViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 10/1/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRecentStourys()
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
    
    func moreClicked(sender: UIButton) {
        let actionSheetController = UIAlertController(title: "Report this Post", message: nil, preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
       
        
        }
        
        let flagActionButton = UIAlertAction(title: "Flag as Inappropriate", style: .default) { action -> Void in
            // send post with "flag" and possibly email?
            actionSheetController.dismiss(animated: true, completion: nil)
            let confirmController = UIAlertController(title: "Flag Content", message: "Are you sure you want to flag this content?", preferredStyle: .alert)
            confirmController.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
                let flagged = DataManager.sharedInstance.recentPosts[sender.tag]
                DataManager.sharedInstance.flagStouryPost(stoury: flagged)
            }))
            confirmController.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            self.present(confirmController, animated: true, completion: nil)
        }
        actionSheetController.addAction(cancelActionButton)
        actionSheetController.addAction(flagActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentList" {
            let stoury = sender as! Stoury
            let destination = segue.destination as! StouryViewController
            destination.mainStoury = stoury            
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
        cell.moreButton.addTarget(self, action: #selector(HomeViewController.moreClicked(sender:)), for: .allTouchEvents)
        let minutes = Int(stoury.length ?? 00.00) / 60 % 60
        let seconds = Int(stoury.length ?? 00.00) % 60
        cell.videoLength.text = String(format:"%02i:%02i", minutes, seconds)
        cell.videoImage.image = UIImage(named: "PlaceHolder")
        cell.tag = indexPath.row
        if let sid = stoury.id {
            cell.stouryID = sid
        }
        
        if let coms = stoury.comments?.count, coms > 0 {
                cell.comments.text = "\(coms) comments"
        }
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let stoury = DataManager.sharedInstance.recentPosts[indexPath.row]
        if (stoury.comments?.count)! > 0 {
         self.performSegue(withIdentifier: "commentList", sender: stoury)
        }
        else {
            let stouryURL = URL(string: stoury.url!)
            let player = AVPlayer(url: stouryURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.view.frame = self.view.bounds
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
}

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

