# Lighstreamer

## Concepts

- __Lighstreamer:__ Lightstreamer enables several forms of real-time messaging. It is flexible enough to be used in any scenario, including mission critical applications.

## Specifications

This project uses Lighstreamer iOS SDK
- Version: 2.1.2
- Compatible with Objective C, Swift
- Min iOS version: 8.0

## Diagrams

### Sequence Diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/Lightstreamer/Diagrams/Sequence%20Diagram%20Lightstreamer.png)

### Components Diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/Lightstreamer/Diagrams/Components%20Diagram%20Lightstreamer.png)

### Deployment Diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/Lightstreamer/Diagrams/Deployment%20Diagram%20Lightstreamer.png)

## Implementation


1. On the `Podfile` add the dependency:

`pod 'Lighstreamer_iOS_Client'`

2. Create a Lighstreamer client, specifying the modo, item, adapter, and elements that will be transferred.

```swift

val serverAddress = "http://YOUR_SERVER_IP:YOUR_SERVER_PORT"
val subscription = Subscription("DISTINCT","chat_room", arrayOf("your","variables")).apply {
    addListener(this@LightstreamerRepository)
    dataAdapter = "CHAT_ROOM"
    requestedSnapshot = "yes"
}
val lsClient = LightstreamerClient(serverAddress,"CHAT").apply {
    connectionDetails.serverAddress = serverAddress
    connect()
    subscribe(subscription)
    addListener(this@LightstreamerRepository)
}


```

3. Optionally, implement the `ClientListener` interface to detect events related to the connection with the server.

4. Subscribre to the channel implementing the `SubscriptionListener` interface, to handle the messages that we receive.

```swift
override fun onItemUpdate(p0: ItemUpdate?) {
    try {
        if(p0 != null && p0.fields != null){
            val message = p0.fields["message"]
            //handle the message as you wish
        }else{
            print("Algo es nulo")
        }


        /*p0?.fields?.get("message")?.let{
            val message = ChatUtils.parseMessage(it)
            messageSubject.onNext(message)
        }*/

    }catch (e: Exception){
        print("Exc: $e")
    }

}

```

5. To send messages, call the `sendMessage` method on the client object (indicating the chat name):

```swift
lsClient.sendMessage("CHAT| your message")
```

The final resut is the class [`LightstreamerChatRepository`](https://github.com/Bruno125/Communication-Demo-Android/blob/documentation/app/src/main/java/com/brunoaybar/chatdemos/data/impl/LighstreamerChatRepository.kt)

```swift
class LightstreamerRepository : ChatRepository,
        SubscriptionListener by LightstreamerListenerLogger,
        ClientListener by LightstreamerListenerLogger{
    override val name: String get() = "Demo Lightstreamer"

    val serverAddress = "http://10.11.80.88:8080"
    val subscription = Subscription("DISTINCT","chat_room", arrayOf("message", "raw_timestamp", "IP","nick")).apply {
        addListener(this@LightstreamerRepository)
        dataAdapter = "CHAT_ROOM"
        requestedSnapshot = "yes"
    }
    val lsClient = LightstreamerClient(serverAddress,"CHAT").apply {
        connectionDetails.serverAddress = serverAddress
        connect()
        subscribe(subscription)
        addListener(this@LightstreamerRepository)
    }

    private val messageSubject: PublishSubject<Message> = PublishSubject.create()

    override fun send(message: String) {
        ChatUtils.createData(message).let {
            lsClient.sendMessage("CHAT| $it")
        }
    }

    override fun receive(): Flowable<Message> {
        return messageSubject.toFlowable(BackpressureStrategy.BUFFER)
    }

    override fun onItemUpdate(p0: ItemUpdate?) {
        try {
            if(p0 != null && p0.fields != null){
                val message = p0.fields["message"]
                if (message != null){
                    val entry = ChatUtils.parseMessage(message)
                    messageSubject.onNext(entry)
                }else{
                    print("Message es null")
                }
            }else{
                print("Algo es nulo")
            }


            /*p0?.fields?.get("message")?.let{
                val message = ChatUtils.parseMessage(it)
                messageSubject.onNext(message)
            }*/

        }catch (e: Exception){
            print("Exc: $e")
        }

    }

}

object LightstreamerListenerLogger : SubscriptionListener, ClientListener{
    //implementing all the methods to log each event...
}

```


## Bibliography

- Lighstreamer. Official page. (http://www.lightstreamer.com/) 2017
