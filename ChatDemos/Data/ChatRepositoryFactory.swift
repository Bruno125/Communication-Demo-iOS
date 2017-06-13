//
//  ChatRepositoryFactory.swift
//  AbblyDemo
//
//  Created by Bruno Aybar on 29/04/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation

class ChatRepositoryFactory{
    private init(){}
    
    static func create(type: ChatType) -> ChatRepository{
        switch type {
        case .ably:
            return AblyChatRepository()
        case .firebase:
            return FirebaseChatRepository()
        case .pubnub:
            return PubnubChatRepository()
        case .lightstreamer:
            return LightStreamerChatRepository()
        default:
            return AblyChatRepository()
        }
    }
    
    
}

enum ChatType {
    case firebase
    case signalR
    case ably
    case pubnub
    case lightstreamer
}
