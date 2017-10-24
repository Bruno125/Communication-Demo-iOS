# Ably

## Concepts

- __Ably:__  a realtime data delivery platform providing developers everything they need to create, deliver and manage complex projects. Provides libraries for:
  - Javascript
  - Android
  - iOS (Objective-C / Swift)
  - .NET
  - NodeJS
  - PHP
  - Java
  - Ruby
  - Python
  - Go

## Specifications

This project uses Ably's iOS SDK
- Version: 0.8.9
- Compatible with Objective C, Swift
- Min iOS version: 8.0

## Diagrams

### Sequence diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/Ably/Diagrams/Sequence%20Diagram%20Ably.png)

### Components diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/Ably/Diagrams/Components%20Diagram%20Ably.png)

### Deployment diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/Ably/Diagrams/Deployment%20Diagram%20Ably.png)

## Implementation

1. On the `Podfile` add the Ably dependency:

`pod 'Ably'`

2. Configure Ably using their API key, and specifying the name of the channel which you'll create to send the messages.

```swift
private static let API_KEY = "YOUR_API_KEY"
private static let CHANNEL_NAME = "chat"
let client = ARTRealtime(key: API_KEY)
let channel = client.channels.get(AblyChatRepository.CHANNEL_NAME)

```

3. Subscribe to the channel, to handle the messages that we receive.

```swift
channel?.subscribe { message in
    let now = String(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))
    guard let data = message.data as? String else {
        return
    }
    //do something with the data
}
```

4. To send a message, the the `publish` method on the `channel` object:

```swift
channel?.publish("send", data: “your message”)
```

The final resut is the class [`AblyChatRepository`](https://github.com/Bruno125/Communication-Demo-iOS/blob/master/ChatDemos/Data/Impl/AblyChatRepository.swift), which implements the ChatRepository protocol

```swift
class AblyChatRepository : ChatRepository{
    
    private static let API_KEY = "gZ_l9g.y5d3Tw:kSJRo2CIeXcw9w2p"
    private static let CHANNEL_NAME = "chat"
    let client = ARTRealtime(key: API_KEY)
    var channel : ARTRealtimeChannel?
    private var messagesSubject = PublishSubject<TextEntry>()
    
    func name() -> String { return "Ably Chat" }
    init() {
        
        client.connection.on { state in }
        channel = client.channels.get(AblyChatRepository.CHANNEL_NAME)
        channel?.subscribe { message in
            let now = String(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))
            print("Llegada: \(now)")
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
    
    func color() -> String {
        return "#f79e20"
    }
    
}

```


## Bibliography

- Ably. Official page. (https://www.ably.io/) 2017

- Ably. Ably's Android SDK integration tutorial. (https://www.ably.io/tutorials/publish-subscribe#lang-android) 2017
