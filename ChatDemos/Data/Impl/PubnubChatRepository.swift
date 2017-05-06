//
//  PubnubChatRepository.swift
//  AbblyDemo
//
//  Created by Bruno Aybar on 30/04/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation
import PubNub
import RxSwift

class PubnubChatRepository : NSObject,ChatRepository,PNObjectEventListener{
    
    private let CHANNEL_NAME = "chat"
    var client: PubNub?
    private var messagesSubject = PublishSubject<TextEntry>()
    
    override init() {
        super.init()
        
        // Initialize and configure PubNub client instance
        let configuration = PNConfiguration(publishKey: "pub-c-8aa801f5-05d1-42bd-9c6f-6ee9e829f37f",
                                            subscribeKey: "sub-c-010f45da-2d2d-11e7-a696-0619f8945a4f")
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client?.addListener(self)
        
        // Subscribe to demo channel with presence observation
        self.client?.subscribeToChannels([CHANNEL_NAME], withPresence: true)
        
    }
    
    func send(message: String){
        self.client?.publish(
            ChatUtils.createData(for: message),
            toChannel: CHANNEL_NAME,
            compressed: false,
            withCompletion: { (status) in
                //do nothing
            })
    }
    
    func receive() -> Observable<TextEntry>{
        return messagesSubject.asObservable()
    }
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        var entry: TextEntry?
        if let data = message.data.message as? [String:Any] {
            entry = ChatUtils.from(dictionary: data)
        }else if let dataString = message.data.message as? String{
            entry = ChatUtils.from(data: dataString)
        }
        if entry != nil{
            messagesSubject.onNext(entry!)
        }
    }
    
}
