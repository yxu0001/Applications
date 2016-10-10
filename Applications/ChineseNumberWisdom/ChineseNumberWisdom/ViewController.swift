//
//  ViewController.swift
//  ChineseNumberWisdom
//
//  Created by Yijia Xu on 10/5/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var keypadView: UIView!
    
    @IBOutlet weak var keypadToBottomConstraint: NSLayoutConstraint!
    
    var numberString: String! = ""
    var engine: NumberWisdomEngine!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        numberLabel.text = ""
        engine = NumberWisdomEngine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(sender: AnyObject) {
        print((sender as! UIButton).titleLabel!.text!)
        
        let buttonInput = (sender as! UIButton).titleLabel!.text!
        
        if (buttonInput == "Clear") {
            reset()
        } else if (buttonInput == "Enter") {
            if let number = Int(numberString),
                (word, result) = engine.findLuck(number) {
                
                print(self.keypadView.frame.origin)
                let height = self.keypadView.frame.size.height
                keypadToBottomConstraint.constant = -height
                
                wordLabel.text = word
                resultLabel.text = result
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                })
            }
        } else {
            numberString = numberString + buttonInput
            numberLabel.text = numberString
        }
    }
    
    
    private func reset() {
        numberString = ""
        numberLabel.text = ""
        wordLabel.text = ""
        resultLabel.text = ""
    }
    
    @IBAction func numberLabelTapped(sender: AnyObject) {
        reset()
        
        print("numberLabelTapped")
        keypadToBottomConstraint.constant = 0.0
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: { finished in })
    }
}

