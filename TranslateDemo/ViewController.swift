//
//  ViewController.swift
//  TranslateDemo
//
//  Created by zang qilong on 10/10/16.
//  Copyright © 2016 zang qilong. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var translateTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var translateButton: UIButton!
    
    
    let translator = TranslateService()

    override func viewDidLoad() {
        super.viewDidLoad()
       // TranslateHandler.sharedInstance.fetchToken()
        translator.fetchBingToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Action
    
    @IBAction func translate() {
        print(translateTextField.text)
//        TranslateHandler.sharedInstance.detectChinese(text: translateTextField.text)
//        print(translateTextField.text!.language())
//        TranslateHandler.sharedInstance.translate(text: translateTextField.text!) { (result) in
//            self.resultLabel.text = result
//        }
        translator.convert(text: translateTextField.text!) { (result) in
            self.resultLabel.text = result
        }
    }

}

