# Firebase

## Concepts

- __Firebase:__ plataform that offers developers a a suite of tools to develop, mantain and monitor múltiple mobile and backend solutions.
- __Firebase Database__: one of the tools offered by Firebase. It allows you to save information on a no relational database. Firebase Realtime Database clients can then subscribe to any changes that occur on this database.

## Specifications

This project uses Firebase iOS SDK
- Version: 3.14.0
- Compatible with Objective C, Swift
- Min iOS version: 8.0

## Diagrams

### Sequence Diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/Firebase/Diagrams/Sequence%20Diagram%20Firebase.png)

### Components Diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/Firebase/Diagrams/Components%20Diagram%20Firebase.png)

### Deployment Diagram

![alt tag](https://raw.githubusercontent.com/Bruno125/Communication-Demo-iOS/master/Documentation/Firebase/Diagrams/Deployment%20Diagram%20Firebase.png)

## Immplementation

1. On the `Podfile` add the Firebase dependency:

`pod 'Firebase'`
`pod 'Firebase/Database'`

2. Add the 'GoogleService-Info.plist' that you can download from the Firebase console.

3. Create a refrence to the database, specifying the name of the node for which you'll publish / send messages.

```swift
FIRApp.configure()
let ref = FIRDatabase.database().reference()

```

4. Subcribe to the database, so that we can be notify when something changes.

```swift
let textsRefs = ref.child(CHANNEL_NAME)
        
textsRefs.observe(.childAdded, with: { (snapshot) -> Void in
    if let info = snapshot.value as? [String: Any] {
        //do something with the data
    }
})

```

5. To send messages, invoke the `push` method:

```swift
self.ref.child(CHANNEL_NAME)
    .childByAutoId()
    .setValue( “your message”)
```

The final resut is the class [`FirebaseChatRepository`](https://github.com/Bruno125/Communication-Demo-iOS/blob/master/ChatDemos/Data/Impl/FirebaseChatRepository.swift), which implements the ChatRepository protocol

```swift
class FirebaseChatRepository : ChatRepository{
    
    private let CHANNEL_NAME = "chat"
    private var messagesSubject = PublishSubject<TextEntry>()
    private var ref : FIRDatabaseReference!
    
    func name() -> String { return "Firebase Chat" }
    init() {
        FIRApp.configure()
        ref = FIRDatabase.database().reference()
        
        let textsRefs = ref.child(CHANNEL_NAME)
        
    textsRefs.observe(.childAdded, with: { (snapshot) -> Void in
            if let info = snapshot.value as? [String: Any], 
        let entry = ChatUtils.from(dictionary: info) {
                self.messagesSubject.onNext(entry)
            }
        })
    }
    
    
    func send(message: String){
        self.ref.child(CHANNEL_NAME)
        .childByAutoId()
        .setValue( ChatUtils.createDictionaryData(for: message))
    }
    
    func receive() -> Observable<TextEntry>{
        return messagesSubject.asObservable()
    }
    
    func color() -> String {
        return "#ffc929"
    }
    
}

```


## Bibliography

- Firebase. Official page. (https://firebase.google.com/) 2017

- Firebase Database. Firebase Database Android SDK tutorial. (https://firebase.google.com/docs/android/setup) 2017
