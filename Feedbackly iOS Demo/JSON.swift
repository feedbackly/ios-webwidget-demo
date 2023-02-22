//
//  JSON.swift
//  Feedbackly iOS Demo
//
//  Created by Işılsu Çitim on 20.02.2023.
//

import Foundation

public class JSON{
    class func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                //print("Something went wrong")
            }
        }
        return nil
    }
}
