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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var textField: UITextField!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
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
        repository.receive().observeOn(MainScheduler.instance).subscribe(onNext: { entry in
            self.entries.insert(entry, at: 0)
            self.tableView.reloadData()
        }).addDisposableTo(disposeBag)
        enableKeyboardHideOnTap()
        navigationBar.topItem?.title = repository.name()
        navigationBar.barTintColor = UIColor(hex: repository.color())
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
    
    // 3
    // Add a gesture on the view controller to close keyboard when tapped
    func enableKeyboardHideOnTap(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil) // See 4.1
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil) //See 4.2
        
        // 3.1
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TextViewController.hideKeyboard))
        
        self.view.addGestureRecognizer(tap)
    }
    
    //3.1
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    //4.1
    func keyboardWillShow(notification: NSNotification) {
        
        let info = notification.userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        self.toolbarBottomConstraint.constant = keyboardFrame.size.height + 5
        UIView.animate(withDuration: duration) { () -> Void in
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    //4.2
    func keyboardWillHide(notification: NSNotification) {
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        self.toolbarBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) { () -> Void in
            
            self.view.layoutIfNeeded()
            
        }
        
    }
    
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

