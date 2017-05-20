//
//  ChatInjection.swift
//  ChatDemos
//
//  Created by Bruno Aybar on 16/05/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation

class ChatInjection {
    static let repository = ChatRepositoryFactory.create(type: .pubnub)
}
