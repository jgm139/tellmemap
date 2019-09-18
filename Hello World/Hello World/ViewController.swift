//
//  ViewController.swift
//  Hello World
//
//  Created by Julia García Martínez on 18/09/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBOutlet weak var hwLabel: UILabel!
    @IBAction func writeHelloWorld(_ sender: Any) {
        hwLabel.text = "Hello World!"
    }
}

