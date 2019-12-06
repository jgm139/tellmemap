//
//  ViewController.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

class NewMessageViewController: UIViewController, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var newSignDescription: UITextView!
    @IBOutlet weak var newSignTitle: UILabel!
    @IBOutlet weak var saveSign: UIButton!
    var newSign: Sign?
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newSignDescription.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.newSignDescription.text = "Description"
        self.newSignDescription.textColor = UIColor.lightGray
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "saveMessageAndLeave") {
            if let title = newSignTitle.text {
                if let description = newSignDescription.text {
                    self.newSign = Sign(name: title, location: "", description: description)
                }
            }
        }
    }
    
    //MARK: UITextViewDelegate functions
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.split(separator: "\n").count > 0 {
            let firstLine = String(textView.text.split(separator: "\n")[0])
            self.newSignTitle.text = firstLine
        } else {
            self.newSignTitle.text = ""
        }
    }

}

