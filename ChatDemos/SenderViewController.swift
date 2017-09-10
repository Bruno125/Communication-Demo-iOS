//
//  SenderViewController.swift
//  ChatDemos
//
//  Created by Fandango Lat on 9/09/17.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation
import RxSwift

class SenderViewController: ViewController {
    
    private let MESSAGES_INTERVAL = 100
    private let MESSAGES_AMOUNT = 50
    private let INITIAL_DELAY = 500
    
    @IBOutlet weak var amountSentLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!

    var repository = ChatInjection.repository
    var disposeBag: DisposeBag! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = UIColor(hex: repository.color())
        amountSentLabel.text = "0/\(MESSAGES_AMOUNT)"
    }
    
    var count = 0
    @IBAction func actionEmit(_ sender: Any) {
        let timer = Observable<Int>.interval(0.1, scheduler: MainScheduler.asyncInstance)
        disposeBag = DisposeBag()
        count = 0
        timer.subscribe{ index in
            self.repository.send(message: "Test \(self.count + 1)")
            self.trackNewEmission()
        }.addDisposableTo(disposeBag)
        
    }
    
    private func trackNewEmission(){
        count+=1
        
        amountSentLabel.text = "\(count)/\(MESSAGES_AMOUNT)"
        if(count >= MESSAGES_AMOUNT){
            disposeBag = nil
        }
    }
    
    
    @IBAction func actionClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
