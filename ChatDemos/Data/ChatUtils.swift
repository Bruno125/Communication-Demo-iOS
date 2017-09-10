//
//  ChatUtils.swift
//  AbblyDemo
//
//  Created by Bruno Aybar on 30/04/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import Foundation

struct ChatUtils{
    
    private static let KEY_VALUE = "value"
    private static let KEY_TIMESTAMP = "timestamp"
    private static let df = DateFormatter()
    
    static func createData(for text: String) -> String{
        let timestamp = getTimestamp()
        print("Sent: \(timestamp)")
        return "{\"\(KEY_TIMESTAMP)\" : \"\(timestamp)\", \"\(KEY_VALUE)\" : \"\(text)\" }"
    
    }
    
    static func createDictionaryData(for text: String) -> [String: String]{
        let timestamp = getTimestamp()
        print("Sent: \(timestamp)")
        return [ KEY_VALUE : text, KEY_TIMESTAMP : timestamp ]
        
    }
    
    static func from(data: String)-> TextEntry?{
        if let data = data.data(using: .utf8) {
            do {
                let info = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                return from(dictionary: info)
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
        
    }
    
    static func from(dictionary: [String:Any]?) -> TextEntry?{
        guard let info = dictionary else {
            return nil
        }
        
        var content = "--", delay = 0, size = "--"
        if let value = info[KEY_VALUE] as? String{
            content = value
            size = "\(content.utf8.count) bytes"
        }
        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
        if let messageTimestamp = info[KEY_TIMESTAMP] as? String,
            let messageDate = df.date(from: messageTimestamp),
            let currentDate = df.date(from: getTimestamp()){
            delay = currentDate.offset(from: messageDate)
        
        }
        
        return TextEntry(value: content, delay: "\(delay) ms", size: size, delayValue: delay)
    }
    
    private static func getTimestamp() -> String {
        //let a =  String(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))
        //print("Salida: \(a)")
        let d = Date()
        df.dateFormat = "y-MM-dd H:m:ss.SSSS"
        return df.string(from: d)
    }
    

}

extension Date {
    
    func offset(from date:Date, components: Set<Calendar.Component> = [.nanosecond]) -> Int {
        let difference = NSCalendar.current.dateComponents(components, from: date)
        return (difference.nanosecond ?? 0) / 1000000
    }
    
}
