//
//  ChatRepository.swift
//  AbblyDemo
//
//  Created by Bruno Aybar on 29/04/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation
import RxSwift

protocol ChatRepository{
    func name() -> String
    func send(message: String)
    func receive() -> Observable<TextEntry>
    func color() -> String
    
}
