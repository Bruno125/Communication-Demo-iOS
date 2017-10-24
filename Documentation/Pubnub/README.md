# Pubnub

## Concepts

- __Pubnub__: Platform that allows you to send and receive messages cross-platform and cross-device with robust yet simple APIs for global publish/subscribe messaging.

## Specifications

This project uses the Pubnub Android SDK
- Version: 4.5.13
- Compatible with Objective C, Swift
- Min iOS version: 8

## Diagrams

### Sequence diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-Android/documentation/Documentation/Pubnub/Diagrams/Diagrama%20de%20secuencia_%20Pubnub.png)

### Components diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-Android/documentation/Documentation/Pubnub/Diagrams/Diagrama%20de%20componentes%20Pubnub.png)

### Deployment diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-Android/documentation/Documentation/Pubnub/Diagrams/Diagrama%20de%20despliege-%20Pubnub.png)

## Implementation

1. On the `Podfile` add the Ably dependency:

`pod 'Pubnub'`

2. Create a Pubnub client, specifying the subscription and publishing keys.

```swift
let configuration = PNConfiguration(publishKey: "PUBLISHER_KEY",
                                    subscribeKey: "SUBSCRIBE_KEY")
self.client = PubNub.clientWithConfiguration(configuration)

```

3. Subscribe to the channel, to handle the messages that we receive.

```swift
self.client?.addListener(self)
self.client?.subscribeToChannels([CHANNEL_NAME], withPresence: true)

func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
  let data = message.data.message as? [String:Any]
  //do something with the data
}

```

4. To send messages, call the `publish` method on the client object:

```swift
self.client?.publish("your message",
            toChannel: CHANNEL_NAME,
            compressed: false,
            withCompletion: { (status) in
                //do nothing
            })

```

The final resut is the class [`PubnubChatRepository`](https://github.com/Bruno125/Communication-Demo-iOS/blob/master/ChatDemos/Data/Impl/PubnubChatRepository.swift), which implements the ChatRepository protocol

```swift
class PubnubChatRepository : NSObject,ChatRepository,PNObjectEventListener{
    
    private let CHANNEL_NAME = "chat"
    var client: PubNub?
    private var messagesSubject = PublishSubject<TextEntry>()
    
    func name() -> String { return "Pubnub Chat" }
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
    
    func color() -> String {
        return "#cf2127"
    }
    
}


```


## Bibliography

- Pubnub. Official Page. (https://www.pubnub.com/) 2017
