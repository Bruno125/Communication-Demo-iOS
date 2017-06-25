//
//  RabbitMQChatRepository.swift
//  ChatDemos
//
//  Created by Bruno Aybar on 13/06/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation
import RxSwift
import RMQClient

class RabbitMQChatRepository : ChatRepository{

    private let URI = "amqp://mobile:1234@10.11.80.94:5673"
    private let USERNAME = "mobile"
    private let PASS = "1234"
    
    let conn : RMQConnection
    
    init() {
        conn = RMQConnection(uri: URI, delegate: RMQConnectionDelegateLogger())
        conn.start()
        subscribe()
    }
    
    func send(message: String){
        
        DispatchQueue.global(qos: .background).async {
            let ch = self.conn.createChannel()
            
            ch.exchangeDeclare("chat", type: "fanout")
        
            
            if let data = ChatUtils.createData(for: message).data(using: .utf8){
                ch.basicPublish(data,
                                routingKey: "",
                                exchange: "chat",
                                properties: [] )
                ch.blockingWait(on: type(of: self))
            }
        }
    }
    
    var messagesSubject = PublishSubject<TextEntry>()
    func receive() -> Observable<TextEntry>{
        return messagesSubject.asObservable()
    }
    
    private func subscribe(){
        
        DispatchQueue.global(qos: .background).async {
            
            let ch = self.conn.createChannel()
            
            ch.exchangeDeclare("chat", type: "fanout")
            
            let name = ch.queue("").name!
            ch.queueBind(name, exchange: "chat", routingKey: "")
            
            let consumer = RMQConsumer(channel: ch, queueName: name, options: .exclusive)
            consumer?.onDelivery({ (message) in
                if let content = String(data: message.body, encoding: .utf8){
                    print("Received \(content))")
                    
                    DispatchQueue.main.async {
                        if let entry = ChatUtils.from(data: content) {
                            self.messagesSubject.onNext(entry)
                        }
                    }
                }
            })
            
            ch.basicConsume(consumer!)
            
        }
        
    }
    
    
    
    private func createConnection() -> RMQConnection{
        return RMQConnection(uri: URI, delegate: RMQConnectionDelegateLogger())
        
    }
    
}
