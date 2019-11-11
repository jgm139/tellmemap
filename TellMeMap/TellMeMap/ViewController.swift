//
//  ViewController.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 27/10/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var newSignDescription: UITextView!
    @IBOutlet weak var newSignTitle: UILabel!
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newSignDescription.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.newSignDescription.text = "Description"
        self.newSignDescription.textColor = UIColor.lightGray
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        self.newSignTitle.text = String(textView.text.split(separator: "\n")[0])
    }

}

