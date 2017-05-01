//
//  FirebaseChatRepository.swift
//  AbblyDemo
//
//  Created by Bruno Aybar on 01/05/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class FirebaseChatRepository : ChatRepository{
    
    private let CHANNEL_NAME = "chat"
    private var messagesSubject = PublishSubject<TextEntry>()
    private var ref : FIRDatabaseReference!
    
    init() {
        FIRApp.configure()
        ref = FIRDatabase.database().reference()
        
        let textsRefs = ref.child(CHANNEL_NAME)
        
        // Listen for new comments in the Firebase database
        textsRefs.observe(.childAdded, with: { (snapshot) -> Void in
            if let info = snapshot.value as? [String: Any], let entry = ChatUtils.from(dictionary: info) {
                self.messagesSubject.onNext(entry)
            }
        })
    }
    
    
    func send(message: String){
        self.ref.child(CHANNEL_NAME).childByAutoId().setValue( ChatUtils.createDictionaryData(for: message))
    }
    
    func receive() -> Observable<TextEntry>{
        return messagesSubject.asObservable()
    }
    
    
    
}
