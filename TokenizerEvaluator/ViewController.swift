//
//  ViewController.swift
//  TokenizerEvaluator
//
//  Created by rahulg on 10/05/18.
//  Copyright © 2018 rahulg. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var dictionaryTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var tokenizerResult: UITextView!
    
    let evaluator = TokenizerEvaluator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        evaluateCurrentInput()
        
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        evaluateCurrentInput()
    }
    
    func evaluateCurrentInput() {
        do {
            let results = try evaluator.evaluateExpression(expression: inputTextField.text!, paramDictionary: dictionaryTextField.text!)
            print(results.1)
            tokenizerResult.text = results.0
            resultLabel.text = results.1
            resultLabel.textColor = .black
        } catch {
            print(error)
            resultLabel.textColor = .red
            resultLabel.text = "Error : \(error)"
            tokenizerResult.text = ""
        }
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        view.endEditing(true)
    }
}
