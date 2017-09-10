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
    let SERVER_URL = "http://192.168.1.38:8080"
    let ADAPTER_SET = "CHAT"
    let DATA_ADAPTER = "CHAT_ROOM"
    
    /* Configuration for online demo server
     let SERVER_URL = "https://push.lightstreamer.com"
     let ADAPTER_SET = "DEMO"
     let DATA_ADAPTER = "CHAT_ROOM"
     */
    
    var _client : LSLightstreamerClient!
    var _subscription : LSSubscription!
    var messagesSubject = PublishSubject<TextEntry>()

    func name() -> String { return "LightStreamer Chat" }
    required override init() {
        
        super.init()
        
        
        _subscription = LSSubscription(subscriptionMode: "DISTINCT", item: "chat_room", fields: ["message", "raw_timestamp", "IP"])
        _subscription.dataAdapter = DATA_ADAPTER
        _subscription.requestedSnapshot = "yes"
        _subscription.addDelegate(self)
        
        
        _client = LSLightstreamerClient(serverAddress: SERVER_URL, adapterSet: ADAPTER_SET)
        _client.connectionDetails.serverAddress = SERVER_URL
        
        
        _client.addDelegate(self)
        _client.subscribe(_subscription)
        _client.connect()
        
    }
    
    func send(message: String){
        
        
        
        // Send the message (executes in background)
        self._client.sendMessage("CHAT|" + ChatUtils.createData(for: message))
    }
    
    func receive() -> Observable<TextEntry>{
        return messagesSubject.asObservable()
    }
    
    func color() -> String {
        return "#689968"
    }
    
}

extension LightStreamerChatRepository : LSClientDelegate,LSSubscriptionDelegate{
    func subscription(_ subscription: LSSubscription, didClearSnapshotForItemName itemName: String?, itemPos: UInt) {
    }
    
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
    
    
    func client(_ client: LSLightstreamerClient, didReceiveServerError errorCode: Int, withMessage errorMessage: String?) {
        NSLog("didReceiveServerError")
    }
    
    func client(_ client: LSLightstreamerClient, didChangeStatus status: String) {
        NSLog("did change status: \(status)")
    }
    
}
