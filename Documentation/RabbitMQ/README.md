# RabbitMQ

## Concepts

- __RabbitMQ__: RabbitMQ is lightweight and easy to deploy on premises and in the cloud. It supports multiple messaging protocols. RabbitMQ can be deployed in distributed and federated configurations to meet high-scale, high-availability requirements.

## Specification

This project uses the RabbitMQ iOS SDK
- Version: 0.10.0
- Compatible with Objective C, Swift
- Min iOS version: 8.0

## Diagrams

### Sequence diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/RabbitMQ/Diagrams/Sequence%20Diagram%20RabbitMQ.png)

### Component diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/RabbitMQ/Diagrams/Components%20Diagram%20RabbitMQ.png)

### Deployment diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/RabbitMQ/Diagrams/Deployment%20diagram%20RabbitMQ.png)

## Implementation


1. On the `Podfile` add the RabbitMQ dependency:

`pod 'RMQClient'`

2. Create a RabbitMQ client, specifying the IP, port, and credentials to connect to the server.

```swift
private let URI = "amqp://mobile:1234@YOUR_IP:YOUR_PORT"
private let USERNAME = "username"
private let PASS = "password"

let conn : RMQConnection

func name() -> String { return "RabbitMQ Chat" }
init() {
    conn = RMQConnection(uri: URI, delegate: RMQConnectionDelegateLogger())
    conn.start()

}


```

3. Subscribe to the channel, to handle the messages that we receive.

```swift
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

```

5. To send messages, call the `publish` method on the client object:

```swift
DispatchQueue.global(qos: .background).async {
    let ch = self.conn.createChannel()

    ch.exchangeDeclare("chat", type: "fanout")


    ch.basicPublish(“your message”,
                        routingKey: "",
                        exchange: "chat",
                        properties: [] )
    ch.blockingWait(on: type(of: self))
}

```

The final resut is the class [`RabbitMQChatRepository`](https://github.com/Bruno125/Communication-Demo-iOS/blob/master/ChatDemos/Data/Impl/RabbitMQChatRepository.swift), which implements the ChatRepository protocol


```swift
class RabbitMQChatRepository : ChatRepository{

    private let URI = "amqp://mobile:1234@10.11.80.80:5673"
    private let USERNAME = "mobile"
    private let PASS = "1234"    
    let conn : RMQConnection
    
    func name() -> String { return "RabbitMQ Chat" }
    init() {
        conn = RMQConnection(uri: URI, delegate: RMQConnectionDelegateLogger())
        conn.start()
        subscribe()
    }
    func color() -> String { return "#ff6600"}
    
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


```


## Bibliography

- RabbitMQ. Official Page - RabbitMQ. (http://www.rabbitmq.com/) 2017
