//
//  AddNewItemTableViewController.swift
//  LostFound
//
//  Created by Haris Shobaruddin Roabbni on 19/09/19.
//  Copyright © 2019 Haris Shobaruddin Robbani. All rights reserved.
//

import UIKit
import MobileCoreServices

class AddNewItemTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemDesc: UITextField!
    @IBOutlet weak var pic: UITextField!
    @IBOutlet weak var itemImage: UIButton!
    
    var key = ""
    var item = ""
    var image = ""
    var desc = ""
    var storedIn = ""
    let date = Date()
    let format = DateFormatter()
    var formattedDate = ""
    let tapRecognizer = UITapGestureRecognizer()
    var newImage: Bool?
    var data = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        format.dateFormat = "yyyy-MM-dd"
        formattedDate = format.string(from: date)
        addTapRecognizer()
        let defaultImage = UIImage(named: "defaultImage")
        data = (defaultImage?.jpegData(compressionQuality: 1.0))!
        print(generateKey())
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "doneSegue" {
            if itemName.text!.isEmpty || pic.text!.isEmpty{
                let alert = UIAlertController(title: "Warning!", message: "Please fill all important field !", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return false
            }
            key = generateKey()
            item = itemName.text!
            desc = itemDesc.text!
            storedIn = pic.text!
            image = "\(key).jpg"
        } else if identifier == "cancleSegue" {
            
        }

        return true
    }
    
    func generateKey()->String{
        let calendar = Calendar.current
        let bulan = calendar.component(.month, from: date)
        let tanggal = calendar.component(.day, from: date)
        let tahun = calendar.component(.year, from: date)
        let jam = calendar.component(.hour, from: date)
        let menit = calendar.component(.minute, from: date)
        let detik = calendar.component(.second, from: date)
        let nanosecond = calendar.component(.nanosecond, from: date)
        key = "\(itemName.text!)-\(tahun)\(bulan)\(tanggal)\(jam)\(menit)\(detik)\(nanosecond)"
        return key
    }
    
    func addTapRecognizer(){
        tapRecognizer.addTarget(self, action: #selector(didTap))
        itemImage.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTap(){
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addFromLibrary = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newImage = true
            }
        }
        
        let takePhoto = UIAlertAction(title: "Open Library", style: .default){ (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newImage = false
            }
        }
        
        let removeImage = UIAlertAction(title: "Remove", style: .default){(action) in
            
        }
        removeImage.setValue(UIColor.red, forKey: "titleTextColor")
        
        let cancle = UIAlertAction(title: "Cancle", style: .cancel)
        
        menu.addAction(addFromLibrary)
        menu.addAction(takePhoto)
        menu.addAction(removeImage)
        menu.addAction(cancle)
        
        self.present(menu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        if mediaType.isEqual(to: kUTTypeImage as String){
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            itemImage.setBackgroundImage(image, for: .normal)
            data = image.jpegData(compressionQuality: 0.3)!
            
            if newImage == true {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageError), nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imageError(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer){
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
