//
//  TSMyStoriViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import GoogleMaps
import AVKit
import AVFoundation

class StourysViewController: UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var listMapControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorColor = UIColor.lightGray
        self.tableView.register(UINib(nibName: "StouryCell", bundle: nil), forCellReuseIdentifier: "StouryCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUsersStourys()
    }
    
    func getUsersStourys() {
        self.loader.hidesWhenStopped = true
        self.loader.startAnimating()
        DataManager.sharedInstance.getUserFeed { success in
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                if success {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func listMapChange(_ sender: UISegmentedControl) {
        
        
        
    }
    
}

extension StourysViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.sharedInstance.userPosts.count
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

extension StourysViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let stouryURL = URL(string: DataManager.sharedInstance.userPosts[indexPath.row].url!)
        let player = AVPlayer(url: stouryURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.view.frame = self.view.bounds
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
    }
    
}


