//
//  TextViewController.swift
//  FirebaseTest
//
//  Created by Bruno Aybar on 04/03/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import UIKit
import Ably
import RxSwift


class TextViewController : UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var textField: UITextField!
    
    var entries : [TextEntry] = []
    var repository = ChatInjection.repository
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        
        setup()
    }
    
    private func setup(){
        repository.receive().subscribe(onNext: { entry in
            self.entries.insert(entry, at: 0)
            self.tableView.reloadData()
        }).addDisposableTo(disposeBag)
    }
    
    
    @IBAction func actionSend(_ sender: Any) {
        guard let text = textField.text else {
            return
        }
        repository.send(message: text)
    }
    
    @IBAction func actionSendBulk(_ sender: Any) {
        let text = JsonFileReader.read(file: "info")
        repository.send(message: text)
    }
    
    private func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func actionClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension TextViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TextEntryCell
        let info = entries[indexPath.row]
        
        cell.valueLabel.text = info.value
        cell.sizeLabel.text = info.size
        cell.delayLabel.text = info.delay
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension TextViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
