//
//  ViewController.swift
//  FindASitter
//
//  Created by Active Mac05 on 14/10/16.
//  Copyright © 2016 techactive. All rights reserved.
//

import UIKit
import Foundation
//import AFOAuth2Manager
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TPFloatRatingViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var childLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    var profileImages : [String] = [String]()
    let  cellIdentifier = "CustomCollectionViewCell"
    var data : [SitterInfo] = [SitterInfo]()
    let alert = UIAlertController(title: "No Internet", message:"Please check your internet connectivity and try again", preferredStyle: .Alert)
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.callApiToGetResponseJson()
        self.callApiToGetToken()
        collectionView.dataSource=self
        collectionView.delegate=self
        profileImages=["Sitter1", "Sitter2", "Sitter3", "Sitter4"]
        data=[SitterInfo(profileImage: "Sitter1", name: "First name1 \nLast Name1", age: "31", rating: 0.0),
              SitterInfo(profileImage: "Sitter2", name: "First name2 \nLast Name2", age: "41", rating: 0.0),
              SitterInfo(profileImage: "Sitter3", name: "First name3 \nLast Name3", age: "41", rating: 0.0),
              SitterInfo(profileImage: "Sitter4", name: "First name4 \nLast Name4", age: "36", rating: 0.0)]
        addressLabel.text="Calle corina 150"
        childLabel.text="1 child"
        dateLabel.text="14/10/2016 5:30"
        timeLabel.text="3:30"
        collectionView.registerNib(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        menuButton.target=self.revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : CustomCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! CustomCollectionViewCell
        
        cell.profileImageView.layer.masksToBounds = true;
        cell.profileImageView.layer.cornerRadius = 15;
        cell.ratingView.delegate = self;
        cell.ratingView.emptySelectedImage = UIImage(named: "Star")
        cell.ratingView.fullSelectedImage = UIImage(named: "StarFull")
        cell.ratingView.contentMode = UIViewContentMode.ScaleAspectFill;
        cell.ratingView.maxRating = 5;
        cell.ratingView.minRating = 0;
        cell.ratingView.rating = 0.0;
        cell.ratingView.editable = false;
        cell.ratingView.floatRatings = true;
        let sitterdata : SitterInfo! = data[indexPath.row]
        if sitterdata != nil {
            print(sitterdata)
            if sitterdata.profileImage.containsString(".jpg") {
               cell.profileImageView.image=UIImage(named: profileImages[indexPath.row])
            }else{
                cell.profileImageView.image=UIImage(named: sitterdata.profileImage)
            }
            
            cell.nameLabel.text=sitterdata.name
            cell.ageLabel.text="Age \(sitterdata.age)"
            cell.ratingView.rating = CGFloat(sitterdata.rating)
        }
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width, self.view.frame.size.height - 227)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    func callApiToGetResponseJson(token : String) {

        if isInternetAvailable() {
            print("*************internet is available")
            let jsonData : [String : AnyObject] = [ "page" : 1,
                                                    "startDate" : "2016-07-01 19:00",
                                                    "endDate" : "2016-07-01 23:00",
                                                    "address" : [ "street" : "Calle San Pedro 91312", "number" : 0, "city" : "Mexico City", "country" : "Mexico", "zipcode" : "04600", "longitude" : -99.157178, "addresTypeIdAddressType" : 1, "latitude" : 19.314252, "state" : "DF" ] ]
            
            let sessionManager : AFHTTPSessionManager = AFHTTPSessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
            sessionManager.requestSerializer=AFJSONRequestSerializer()
            sessionManager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
            sessionManager.requestSerializer.setValue(token, forHTTPHeaderField: "Authorization")
            sessionManager.POST("http://dev-api.nauroo2.com/userClient/search", parameters: jsonData, progress: nil, success: { (task, responseObject) in
                
                if let convertedJsonIntoArray = responseObject?.objectForKey("data") as? [[String : AnyObject]] {
                    print("array = \(convertedJsonIntoArray)")
                    self.data.removeAll()
                    for object in convertedJsonIntoArray {
                        let obj = object
                        print(obj)
                        let sitter = SitterInfo(profileImage: "", name: "", age: "", rating: 0.0)
                        var name = ""
                        for (key, value) in obj {
                            print("Property:\(key) and value = \(value)")
                        }
                        if let age = obj["age"] as? Int {
                            sitter.age="\(age)"
                            print(age)
                        }
                        if let Fname = obj["firstName"] as? String {
                            name = Fname
                            print(Fname)
                        }
                        if let Lname = obj["lastName"] as? String {
                            print(Lname)
                            name += "\n\(Lname)"
                        }
                        if let rating = obj["rating"] as? NSNumber {
                            print(rating)
                            sitter.rating=rating.floatValue
                        }
                        if let image = obj["photo1"] as? String {
                            print(image)
                            sitter.profileImage=image
                        }
                        sitter.name=name
                        self.data.append(sitter)
                    }
                    print("printing shop array after adding = \(self.data)")
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView.reloadData()
                    })
                } else {
                    print("response is not an array")
                }
                
            }) { (task1, error) in
                print("token: \(error)")
            }
        }else {
            print("*************internet is not available")
            dispatch_async(dispatch_get_main_queue(), {
                self.alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                self.presentViewController(self.alert, animated: true, completion: nil)
            })
        }

    }
    
    
    func callApiToGetToken(){
        if isInternetAvailable() {
            var tokenString = ""
            let jsonData : [String : AnyObject] = [ "password" : "hola",
                                                    "username" : "52-5541302206",
                                                    "grant_type" : "password",
                                                    "scope" : "read write",
                                                    "client_secret" : "123456",
                                                    "client_id" : "clientapp",
                                                    "clientapp" :"123456"
            ]
            let manager = AFOAuth2Manager(baseURL: NSURL(string: "http://dev-api.nauroo2.com")!, clientID: "clientapp", secret: "123456")
            manager.authenticateUsingOAuthWithURLString("/oauth/token", parameters: jsonData, success: { (credential : AFOAuthCredential) in
                print("token: \(credential.accessToken)")
                tokenString="Bearer \(credential.accessToken)"
                self.callApiToGetResponseJson(tokenString)
            }) { (error : NSError) in
                print("token: \(error)")
            }
        }else{
            print("*************internet is not available")
            dispatch_async(dispatch_get_main_queue(), {
                self.alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                self.presentViewController(self.alert, animated: true, completion: nil)
            })
        }
    }
    
    
    func isInternetAvailable()->Bool {
        let reachability = Reachability.reachabilityForInternetConnection()
        let internetStatus = reachability.currentReachabilityStatus()
        
        if (internetStatus != NotReachable) {
            return true
        }else {
            return false
        }
    }
}
