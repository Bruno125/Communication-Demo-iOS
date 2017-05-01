//
//  AblyChatRepository.swift
//  AbblyDemo
//
//  Created by Bruno Aybar on 29/04/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation
import RxSwift
import Ably

class AblyChatRepository : ChatRepository{
    
    private static let API_KEY = "gZ_l9g.y5d3Tw:kSJRo2CIeXcw9w2p"
    private static let CHANNEL_NAME = "chat"
    let client = ARTRealtime(key: API_KEY)
    var channel : ARTRealtimeChannel?
    let dateFormatter = DateFormatter()
    private var messagesSubject = PublishSubject<TextEntry>()
    
    init() {
        
        client.connection.on { state in }
        channel = client.channels.get(AblyChatRepository.CHANNEL_NAME)
        channel?.subscribe { message in
            guard let data = message.data as? String else {
                return
            }
            
            if let entry = ChatUtils.from(data: data){
                self.messagesSubject.onNext(entry)
            }
        }

    }
    
    func send(message: String){
        channel?.publish("send", data: ChatUtils.createData(for: message))
    }
    
    func receive() -> Observable<TextEntry>{
        return messagesSubject.asObservable()
    }
    
    
    
}
