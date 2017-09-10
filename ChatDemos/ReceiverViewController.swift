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
    
    private var EXPECTED_MESSAGES_COUNT = 50
    
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var repository = ChatInjection.repository
    var disposeBag: DisposeBag? = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = UIColor(hex: repository.color())
        counterLabel.text = "0/\(EXPECTED_MESSAGES_COUNT)"
        setup()
    }
    
    private func setup(){
        disposeBag = DisposeBag()
        repository.receive().observeOn(MainScheduler.instance).subscribe(onNext: {
            self.receiveMessage(message: $0)
        }).addDisposableTo(disposeBag!)
    }
    
    private var entries = [TextEntry]()
    private func receiveMessage(message: TextEntry){
        entries.append(message)
        counterLabel.text = "\(entries.count)/\(EXPECTED_MESSAGES_COUNT)"
        
        if(entries.count >= EXPECTED_MESSAGES_COUNT){
            shareResults()
            disposeBag = nil
        }
    }
    
    private func shareResults(){
        let textToWrite = asTabbedText(data: entries)
        let fileName = "mediciones-iOS-\(Date()).txt"
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do{
                let path = dir.appendingPathComponent(fileName)
                try textToWrite.write(to: path, atomically: false, encoding: .utf8)
                
                let objectsToShare = [path]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                self.present(activityVC, animated: true, completion: nil)
                
            }catch{
                print("cannot write file: \(error)")
            }
            
        }

    }
    
    
    private func asTabbedText(data: [TextEntry]) -> String{
        return entries.enumerated()
            .map{ index,element in "\(index+1)\t\(element.delayValue)" }
            .reduce("", { a, b in "\(a)\n\(b)"})
    }
    
    @IBAction func actionClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
