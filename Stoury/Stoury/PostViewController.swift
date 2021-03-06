//
//  PostViewController.swift
//  Stoury
//
//  Created by Jesse Tello Jr. on 2/14/17.
//  Copyright © 2017 jt. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GooglePlaces

protocol StouryCreationDelegate: class {
    func addStouryComment()
}

class PostViewController: UIViewController, UINavigationControllerDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var createPostButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    let imagePicker = UIImagePickerController()
    var likelyPlaces = [GMSPlace]()
    var existingStouryID:String?
    var recentStourys = [Stoury]()
    var selectedPlace: GMSPlace?
    let placesClient = GMSPlacesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.sharedInstance.getLocation()
        self.imagePicker.delegate = self
        self.createPostButton.layer.cornerRadius = 4
        self.tableView.tableFooterView = UIView()
        self.nearMePlaces()
        self.navigationController?.navigationBar.topItem?.title = "Post"
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.AddToExistingStoury(notification:)), name: NSNotification.Name(rawValue: "PresentCamera"), object: nil)
    }
    
    func presentCamera() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecordNav") as? UINavigationController {
            let rc = vc.childViewControllers[0] as? RecordViewController
            if selectedPlace != nil {
                rc?.selectedPlace = selectedPlace
            } else if existingStouryID != nil {
                rc?.existingID = existingStouryID
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func AddToExistingStoury(notification: Notification) {
        if let exist = notification.userInfo?["stouryID"] as? String {
            existingStouryID = exist
            self.presentCamera()
        }
    }
    
    private func authorizeRecordingView() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .notDetermined ||  AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (videoGranted: Bool) -> Void in
                if (videoGranted) {
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (audioGranted: Bool) -> Void in
                        if (audioGranted) {
                            DispatchQueue.main.async {
                                // Both video & audio granted
                                self.presentCamera()
                            }
                        } else {
                            // Rejected audio
                            print("rejected audio")
                        }
                    })
                } else {
                    // Rejected video
                    print("rejected video")
                }
            })
        } else {
            DispatchQueue.main.async {
                self.presentCamera()
            }
        }
    }
    
    @IBAction func createNewPost(_ sender: UIButton) {
        self.authorizeRecordingView()
    }

    @IBAction func createStouryFromList(_ sender: UIButton) {
            let cell = sender.superview?.superview
            let indexPath = self.tableView.indexPath(for: cell as! UITableViewCell)
            selectedPlace = self.likelyPlaces[(indexPath?.row)!]
            self.authorizeRecordingView()
    }
    
    func nearMePlaces() {
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()
        placesClient.currentPlace(callback: { [weak self] (placeLikelihoodList, error) -> Void in
            self?.activityIndicator.stopAnimating()
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
    
    func addStouryComment() {
        self.presentCamera()
    }
}


extension PostViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likelyPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Nearby Places"
    }
    
}

extension PostViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}


extension PostViewController: UIImagePickerControllerDelegate {
    
    // Finished recording a video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            if let videoData = NSData(contentsOf: pickedVideo as URL) {
                print(pickedVideo)
                print(videoData)
            }
            self.dismiss(animated: true, completion: nil)
            
        }
        
        self.imagePicker.dismiss(animated: true, completion: {
            // Anything you want to happen when the user saves an video
        })
    }
}


