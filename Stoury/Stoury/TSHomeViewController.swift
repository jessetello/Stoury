//
//  TSFeedViewController.swift
//  TripStori
//
//  Created by Jesse Tello Jr. on 10/1/16.
//  Copyright © 2016 Tello. All rights reserved.
//

import UIKit
import GooglePlaces

class TSHomeViewController: UIViewController {
   
    @IBOutlet var tableView: UITableView!
    
    var likelyPlaces = [GMSPlace]()
    var searchArray = [TSStoury]()
    let homeList = ["Restaurants","Bars","Hotels", "Nightlife", "Coffee & Tea"]
    let placesClient = GMSPlacesClient()
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
        
        nearMePlaces()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func nearMePlaces() {
        placesClient.currentPlace(callback: { [weak self] (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    let place = likelihood.place
                    self?.likelyPlaces.append(place)
                }
                self?.tableView.reloadData()
            }
        })
    }
    
}


extension TSHomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return homeList.count
        }
        return likelyPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = homeList[indexPath.item]
            cell.textLabel?.textColor = UIColor.black
            return cell
            
        } else {
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "NearMeCell", for: indexPath) as! NearMeCell
            cell.name.text = likelyPlaces[indexPath.row].name
            cell.address.text = likelyPlaces[indexPath.row].formattedAddress
            cell.ratingNum.text = String(likelyPlaces[indexPath.row].rating)
            
            DispatchQueue.main.async {
            // get recent user storys instead
                
            GMSPlacesClient.shared().lookUpPhotos(forPlaceID: self.likelyPlaces[indexPath.row].placeID) { (photos, error) -> Void in
                    if let error = error {
                        // TODO: handle the error.
                        print("Error: \(error.localizedDescription)")
                    } else {
                        if let firstPhoto = photos?.results.first {
                            GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: {
                                (photo, error) -> Void in
                                if let error = error {
                                    // TODO: handle the error.
                                    print("Error: \(error.localizedDescription)")
                                } else {
                                    DispatchQueue.main.async {
                                        cell.placeImage.image = photo
                                    }
                                }
                            })
                            
                        }
                    }
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Near Me"
        }
        return ""
    }
    
}

extension TSHomeViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 50
        }
        return 90
    }
}

extension TSHomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

