# Realtime iOS Communication Technologies

This project was developed considering that no matter the inner behavior of any technology that allows us to establish realtime communication between mobile devices, the most basic requirements they must fullfill are:   

- Sending messages
- Receiving messages

## Defining the interface

Considering this, we create a protocol `ChatRepository` that defines two methods, one to send and another to receive data:

```swift
protocol ChatRepository{
    func send(message: String)
    func receive() -> Observable<Message>
}
```

The `send` method allows the client to send an string of text, for itto be distributed to the other clients.

The `receive` method returns `∫<Message>`. This represents an stream of messages, which will allow us to be notified each time another device emits a message. The `Observable` class comes from the RxSwift library.

Once the interface is defined, each technology will implement it using it's own dependencies. We have created 5 implementations:

- AblyRepository
- FirebaseRepository
- PubnunbRepository
- LightstreamerRepository
- RabbitMQRepository

## Project Targets

We'll use the same project to generate the Android apps for each technology. This way, we'll make sure that each one of them is executing on the same scenario. To achieve this, the project will be based on multiple targets.

1. Create `Targets` folder, and inside create a folder for each technology.
2. Inside each folder, create the files `ChatInjection.swift` and `Info.plist`
3. Open `ChatInjection.swift`, and create an static variable that returns an implementation of the ChatRepository

```swift
class ChatInjection {
    static let repository = ChatRepositoryFactory.create(type: .rabbitmq)
}
```


4. Open the `Info.plist` file and define the configurations for each target. In our case, all targets share the same configuration.
5. Open the `.xcproject` file, and you'll only see one target the first time. We select it, and duplicate.
6. Change the name, icons and bundle identifier of the target and edit the `.plist` file as desired.
7. Repeat steps 5-7 for each technology.
8. Go back to the `Targets` folder, and for each `ChatInjection.swift` and `Info.plist`, change the Target Membership to the appropriate target.



