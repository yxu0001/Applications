//
//  ViewController.swift
//  ChineseNumberWisdom
//
//  Created by Yijia Xu on 10/5/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var keypadView: UIView!
    
    @IBOutlet weak var keypadToBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var numberTextField: UITextField!

    let titleString = "数字吉凶测试"
    let placeholderNumberString = " "
    let placeholderResultString = "吉或凶"
    let placeholderWordString = "词曰："
    let placeholderTestField = "请输入数字"
    
    var numberString: String! = ""
    var engine: NumberWisdomEngine!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        titleLabel.text = titleString
        numberLabel.text = placeholderNumberString
        numberTextField.placeholder = placeholderTestField
        wordLabel.text = placeholderWordString
        resultLabel.text = placeholderResultString

        engine = NumberWisdomEngine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(_ sender: AnyObject) {
        print((sender as! UIButton).titleLabel!.text!)
        
        let buttonInput = (sender as! UIButton).titleLabel!.text!
        
        if (buttonInput == "C") {
            reset()
        } else if (buttonInput == "Enter") {
            if let number = Int(numberString),
                let (word, result) = engine.findLuck(number) {
                wordLabel.text = word
                resultLabel.text = result

                /*
                if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
                    print(self.keypadView.frame.origin)
                    let height = self.keypadView.frame.size.height
                    keypadToBottomConstraint.constant = -height
                    
                    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: { finished in
                    })
                }*/
            }
        } else if (buttonInput == "<") {
            if numberString.characters.count > 1 {
                let prevIndex = numberString.index(before: numberString.endIndex)
                numberString = numberString.substring(to: prevIndex)
                //numberLabel.text = numberString
                numberTextField.text = numberString
                if let number = Int(numberString),
                    let (word, result) = engine.findLuck(number) {
                    wordLabel.text = word
                    resultLabel.text = result
                }
            } else {
                reset()
            }
        }
        else {
            numberString = numberString + buttonInput
            //numberLabel.text = numberString
            numberTextField.text = numberString
            
            if let number = Int(numberString),
                let (word, result) = engine.findLuck(number) {
                wordLabel.text = word
                resultLabel.text = result
            }
        }
    }
    
    
    fileprivate func reset() {
        numberString = ""
        numberLabel.text = placeholderNumberString
        wordLabel.text = placeholderWordString
        resultLabel.text = placeholderResultString
        numberTextField.text = nil
    }
    
    @IBAction func numberLabelTapped(_ sender: AnyObject) {
        reset()
        
        print("numberLabelTapped")
        
        /*
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            keypadToBottomConstraint.constant = 0.0
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                self.view.layoutIfNeeded()
                }, completion: { finished in })
        }*/
    }
}

