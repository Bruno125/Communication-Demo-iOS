//
//  ReceiverViewController.swift
//  ChatDemos
//
//  Created by Fandango Lat on 9/09/17.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation
import RxSwift

class ReceiverViewController: ViewController {
    
    private var EXPECTED_MESSAGES_COUNT = 100
    
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var repository = ChatInjection.repository
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = UIColor(hex: repository.color())
        counterLabel.text = "0/\(EXPECTED_MESSAGES_COUNT)"
        
        setup()
    }
    
    private func setup(){
        
        repository.receive().observeOn(MainScheduler.instance).subscribe(onNext: {
            self.receiveMessage(message: $0)
        }).addDisposableTo(disposeBag)
    }
    
    private var entries = [TextEntry]()
    private func receiveMessage(message: TextEntry){
        entries.append(message)
        counterLabel.text = "\(entries.count)/\(EXPECTED_MESSAGES_COUNT)"
        
        if(entries.count >= EXPECTED_MESSAGES_COUNT){
            
        }
    }
    
    @IBAction func actionClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
