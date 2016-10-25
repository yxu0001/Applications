//
//  NumberWisdomEngine.swift
//  ChineseNumberWisdom
//
//  Created by Yijia Xu on 10/5/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//

import Foundation

class NumberWisdomEngine {
    
    let divider = 80
    var numberWisdomArray: NSArray?
    
    init() {
        if let path = Bundle.main.path(forResource: "ChineseNumberWisdom", ofType: "plist") {
            numberWisdomArray = NSArray(contentsOfFile: path)
        }
    }
    
    fileprivate func remainder(_ number: Int) -> Int {
        
        return number % divider
    }
    
    
    func findLuck(_ number: Int) -> (String, String)? {
        
        var index = remainder(number) - 1
        
        if index < 0 {
            index = divider - 1
        }
        
        if let numberWisdomArray = numberWisdomArray {
            let dict = numberWisdomArray[index] as! NSDictionary
            
            return (dict["word"] as! String, dict["result"] as! String)
        }
        
        
        return nil
    }
    
}
