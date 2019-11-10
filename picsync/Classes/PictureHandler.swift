//
//  InfoHandler.swift
//  SNNTG
//
//  Created by David Schmotz on 06.06.19.
//  Copyright © 2019 DavidSchmotz. All rights reserved.
//

import Foundation
import UIKit

class PictureHandler {

    /*
     - Get Timetable
     - Go through Array
     - Check Version Tag with local Version Tag (also possible that no local one exists)
     - if local != external {
        Download and resave to filesys
     } else {
        Take Picture prop from Artist and get the pic from local filesys
     }
    */
    
    static func servePictures(data: Dictionary<String, [Dictionary<String, Any>]>, destination: UnsafeMutablePointer<Dictionary<String, UIImage>>, notification: String) {
        for (_, values) in data {
            for value in values {
                guard let arr = value["Artist"] as? Dictionary<String, Any> else {
                    print("Couldnt cast")
                    continue
                }
                
                if let pictureName = arr["Picture"] as? String {
                    if let name = arr["Name"] as? String {
                        let localV = UserDefaults.standard.integer(forKey: name)
                        if let externalV = arr["Picture_v"] as? Int {
                            if (localV == externalV) {
                                // get image from directory
                                guard let img = loadImageFromDiskWith(fileName: name) else { continue }
                                destination.pointee[name] = img
                            } else {
                                DispatchQueue.main.async {
                                    NetworkMechanics.getImageFromUrl(urlPrefix: pictureName, name: name, target: destination, v: externalV, notification: notification)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                NetworkMechanics.getImageFromUrl(urlPrefix: pictureName, name: name, target: destination, v: 0, notification: notification)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    //loader func
    static func loadImageFromDiskWith(fileName: String) -> UIImage? {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsUrl.appendingPathComponent(fileName+".jpg")
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print("Not able to load image\(error)")
            }
        }
        
        return nil
    }
    
    
    //  Saver function
    static func saveImageToDisk(img: UIImage, imageName: String, v: Int) {
        // get the documents directory url
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // choose a name for your image
        let fileName = imageName + ".jpg"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = img.UIImageJPEGRepresentation(compressionQuality:  1.0) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
                UserDefaults.standard.set(v, forKey: imageName)
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    func checkVersions(versions: Dictionary<String, Int>) {
        
    }
    
    func checkId(key: String, version: Int) {
        
    }
    
    func initEmptyVersionStorage(data: Dictionary<String, [Dictionary<String, Any>]>) {
        
    }
}
