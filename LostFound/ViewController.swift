//
//  ViewController.swift
//  LostFound
//
//  Created by Haris Shobaruddin Roabbni on 18/09/19.
//  Copyright © 2019 Haris Shobaruddin Robbani. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewController: UITableView!
    
    var stuffImahe: UIImage!
    
    var stuffName: String!
    
    var publisedDate: String!
    
    var items: [StuffItem] = []
    
    var orderedItems: [StuffItem] = []
    
    var user: User!
    
    var ref: DatabaseReference!
    
    var storageRef: StorageReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableViewController.delegate = self
        tableViewController.dataSource = self
        ref = Database.database().reference(withPath: "stuff-list")
        storageRef = Storage.storage().reference()
        let query = ref.queryOrdered(byChild: "completed").queryEqual(toValue: false)
//        Auth.auth().signIn(withEmail: self.user.email, password: self.user.pa) { user, error in
//            if let error = error, user == nil {
//                let alert = UIAlertController(title: "Sign In Failed",
//                                              message: error.localizedDescription,
//                                              preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//
//                self.present(alert, animated: true, completion: nil)
//            }else{
////                self.performSegue(withIdentifier: self.loginToList, sender: nil)
//                print("Grant..!")
//            }
//        }
        
//        query.observe(.value, with: { (snapshot) in
//            var newItems: [StuffItem] = []
//            for child in snapshot.children {
//                if let snapshot = child as? DataSnapshot,
//                    let stuffItem = StuffItem(snapshot: snapshot) {
//                    newItems.append(stuffItem)
//                }
//            }
//            self.orderedItems = newItems
//            self.tableViewController.reloadData()
//        })
        
        query.observe(.value, with: { snapshot in
            var newItems: [StuffItem] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let stuffItem = StuffItem(snapshot: snapshot) {
                    newItems.append(stuffItem)
                }
            }
            print("reloaded")
            self.items = newItems
            self.tableViewController.reloadData()
            print("reloaded...")
        })
        
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        }
    }
    
    func removeAllSelection(tableView: UITableView){
        for cell in tableView.visibleCells {
            cell.setSelected(false, animated: true)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stuffitem = items[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "stuffCell", for: indexPath) as? StuffTableViewCell else {return UITableViewCell()}
            cell.stuffName.text = stuffitem.stuffName
            cell.postDate.text = stuffitem.postDate
            cell.currentlyIn.text = stuffitem.storedIn
            let storage = storageRef.storage.reference(forURL: stuffitem.stuffURL)
            storage.getData(maxSize: 1 * 9024 * 9024) { (data, error) -> Void in
                // Create a UIImage, add it to the array
                let compressedImage = UIImage(data: data!)?.jpegData(compressionQuality: 0)
                cell.stuffImage.image = UIImage(data: compressedImage!)
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        let alert = UIAlertController(title: "Detail", message: "Item : \(item.stuffName) \n Description : \(item.stuffDescription) \n Post Date : \(item.postDate) \n Currently In : \(item.storedIn) \n Posted By : \(item.addedByUser)", preferredStyle: .alert)
        let take = UIAlertAction(title: "It's Mine !", style: .default){(action) in
            
            let itemRef = self.ref.child(item.key.lowercased())
            let stuffItem = StuffItem(stuffName: item.stuffName,
                                      stuffImage: item.stuffImage,
                                      postDate: item.postDate,
                                      storedIn: item.storedIn,
                                      stuffDescription: item.stuffDescription,
                                      addedByUser: self.user.email,
                                      completed: true,
                                      stuffURL: item.stuffURL)
            itemRef.setValue(stuffItem.toAnyObject())
            
        }
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel){(action) in
            self.removeAllSelection(tableView: self.tableViewController)
        }
        dismiss.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(take)
        alert.addAction(dismiss)
//        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.50)
//        alert.view.addConstraint(height);
        self.present(alert, animated: true, completion: nil)
        print("index : ", indexPath)
    }
    
    @IBAction func cancle(segue: UIStoryboardSegue) {
        removeAllSelection(tableView: tableViewController)
    }
    
    @IBAction func done(segue: UIStoryboardSegue) {
        removeAllSelection(tableView: tableViewController)
        let addItemVC = segue.source as! AddNewItemTableViewController
        
        let imageRef = self.storageRef.child("\(addItemVC.key).jpg")
        let itemRef = self.ref.child(addItemVC.key.lowercased())
        
        let uploadTask = imageRef.putData(addItemVC.data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                print("error uploading image !")
                return
            }
            
            let size = metadata.size
            // access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // an error occurred!
                    return
                }
                let stuffItem = StuffItem(stuffName: addItemVC.item,
                                          stuffImage: addItemVC.image,
                                          postDate: addItemVC.formattedDate,
                                          storedIn: addItemVC.storedIn,
                                          stuffDescription: addItemVC.desc,
                                          addedByUser: self.user.email,
                                          completed: false,
                                          stuffURL: "\(downloadURL)")
                itemRef.setValue(stuffItem.toAnyObject())
                print("download url : ", downloadURL)
            }
        }
        
        let uploadStatus = uploadTask.observe(.progress){(snapshot) in
            print("upload status : ", snapshot.progress!.isFinished)
        }
    }
    @IBAction func signOutDidTouch(_ sender: Any) {
        let user = Auth.auth().currentUser!
        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
        
        // 2
        onlineRef.removeValue { (error, _) in
            
            // 3
            if let error = error {
                print("Removing online failed: \(error)")
                return
            }
            
            // 4
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: true, completion: nil)
            } catch (let error) {
                print("Auth sign out failed: \(error)")
            }
        }
    }
    

}

