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

    private let URI = "amqp://mobile:1234@10.11.80.78:5673"
    private let USERNAME = "mobile"
    private let PASS = "1234"
    
    let channel: RMQChannel
    
    init() {
        publishToAMQP()
        
    }
    
    let queue = Queue<String>()
    func send(message: String){
        // Send the message (executes in background)
        let x = channel.fanout("chats")
        x.publish(ChatUtils.createData(for: message).data(using: .utf8))
    }
    
    var messagesSubject = PublishSubject<TextEntry>()
    func receive() -> Observable<TextEntry>{
        return messagesSubject.asObservable()
    }
    
    private func publishToAMQP(){
        DispatchQueue.global(qos: .background).async {
            while(true){
                let connection = self.createConnection()
                let ch = connection.createChannel()
                ch.confirmSelect()
                
                while(true){
                    if let message = queue.front{
                        ch.
                    }
                    
                }
                
            }
            
            
            
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
            }
        }
    }
    
    
    private func createConnection() -> RMQConnection{
        return RMQConnection(uri: URI, delegate: RMQConnectionDelegateLogger())
        
    }
    
}

public struct Queue<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    public var front: T? {
        return array.first
    }
}
