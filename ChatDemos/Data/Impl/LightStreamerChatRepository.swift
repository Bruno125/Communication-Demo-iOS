//
//  LightStreamerChatRepository.swift
//  ChatDemos
//
//  Created by Bruno Aybar on 13/05/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation
import RxSwift

class LightStreamerChatRepository: NSObject, ChatRepository{
    
    // Configuration for local installation
    let SERVER_URL = "http://10.11.80.79:8080"
    let ADAPTER_SET = "CHAT"
    let DATA_ADAPTER = "CHAT_ROOM"
    
    /* Configuration for online demo server
     let SERVER_URL = "https://push.lightstreamer.com"
     let ADAPTER_SET = "DEMO"
     let DATA_ADAPTER = "CHAT_ROOM"
     */
    
    let _client : LSLightstreamerClient
    let _subscription : LSSubscription
    var messagesSubject = PublishSubject<TextEntry>()

    required override init() {
        _client = LSLightstreamerClient(serverAddress: SERVER_URL, adapterSet: ADAPTER_SET)
        _subscription = LSSubscription(subscriptionMode: "DISTINCT", item: "chat_room", fields: ["message", "raw_timestamp", "IP"])
        super.init()
        
        // Start LS connection (executes in background)
        self._client.connect()
        
        // Start subscription (executes in background)
        self._subscription.dataAdapter = DATA_ADAPTER
        self._subscription.requestedSnapshot = "yes"
        self._subscription.addDelegate(self)
        self._client.subscribe(_subscription)
    }
    
    func send(message: String){
        // Send the message (executes in background)
        self._client.sendMessage("CHAT|" + message)
    }
    
    func receive() -> Observable<TextEntry>{
        return messagesSubject.asObservable()
    }
    
}

extension LightStreamerChatRepository : LSClientDelegate,LSSubscriptionDelegate{
    func subscription(_ subscription: LSSubscription, didClearSnapshotForItemName itemName: String?, itemPos: UInt) {}
    
    func subscription(_ subscription: LSSubscription, didEndSnapshotForItemName itemName: String?, itemPos: UInt) {
        NSLog("LS Subscription snapshot did end")
    }
    
    func subscription(_ subscription: LSSubscription, didUpdateItem itemUpdate: LSItemUpdate) {
        let message = itemUpdate.value(withFieldName: "message") ?? ""
        if let entry = ChatUtils.from(data: message){
            self.messagesSubject.onNext(entry)
        }
    }
    
    func subscription(_ subscription: LSSubscription, didFailWithErrorCode code: Int, message: String?) {
        NSLog("LS Subscription did fail with error (code: \(code), message: \(message)")
    }
    
    func subscription(_ subscription: LSSubscription, didLoseUpdates lostUpdates: UInt, forItemName itemName: String?, itemPos: UInt) {
        NSLog("LS Subscription did lose updates (lost updates: \(lostUpdates), item name: \(itemName), item pos: \(itemPos)")
    }
    
    func subscriptionDidSubscribe(_ subscription: LSSubscription) {
        NSLog("LS Subscription did susbcribe")
    }
    
    func subscriptionDidUnsubscribe(_ subscription: LSSubscription) {
        NSLog("LS Subscription did unsusbcribe")
    }
    
    
}
