//
//  TSMyStoriViewController.swift
//  tripstori
//
//  Created by Jesse Tello Jr. on 9/18/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import GoogleMaps

class StourysViewController: UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var tableView: UITableView!
    var userStourys = [Stoury]()
    override func viewDidLoad() {
        super.viewDidLoad()
        //getUsersStourys()
    }
    
    func getUsersStourys() {
        DataManager.sharedInstance.getUserFeed { success, stourys in
            
            
            
        }
    }
}

extension StourysViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userStourys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "StouryCell", for: indexPath) as! StouryCell
        
        
        return cell
    }
}



extension StourysViewController: UITableViewDelegate {
    
    
    
}


