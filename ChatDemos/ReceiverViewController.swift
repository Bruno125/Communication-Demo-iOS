//
//  ReceiverViewController.swift
//  ChatDemos
//
//  Created by Fandango Lat on 9/09/17.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation

class ReceiverViewController: ViewController {
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    var repository = ChatInjection.repository
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = UIColor(hex: repository.color())
    }
    
    
    @IBAction func actionClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
