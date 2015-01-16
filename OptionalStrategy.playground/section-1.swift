// Playground - noun: a place where people can play

//This outlines a strategy for dealing with optional unbinding
//Will show counter example soon

import UIKit

protocol Decoding {
    
    init?(decoder: Decoder)
    
}

extension Optional {
    
    func getOrElse(defaultValue: T) -> T {
        if self == nil {
            return defaultValue
        }
        else {
            return self!
        }
    }
    
    func flatMap<S>(f: (T) -> S) -> S? {
        if self == nil {
            return nil
        }
        else {
            return f(self!)
        }
    }
    
    
}

extension Decoder {
    
    var string: String? {
        return self.val as? String
    }
    
    var int: Int? {
        return self.val as? Int
    }
    
    var double: Double? {
        return self.val as? Double
    }
    
    var float: Float? {
        return self.val as? Float
    }
    
    var bool: Bool? {
        return self.val as? Bool
    }
    
    var errorMessage: String? {
        if let err = self.err as NSError? {
            return err.userInfo!["message"] as String?
        }
        return nil
    }
    
}

class Person : Decoding {
    
    let name: String
    let repairs: [String]
    let carName: String?
    let firstFriend: String
    
    //The GOOD - do this
    required init?(decoder: Decoder) {
        self.name = decoder["name"].string!
        self.carName = decoder["car"]["name"].string
        self.repairs = decoder["car"]["repairs"].arr.flatMap { rep in
            map(rep, { x in x.string! })
        } ?? []
        self.firstFriend = decoder["friends"][0]["name"].string!
    }
    
    
    //The BAD - Don't do this
    init(dict: [String:AnyObject]) {
        self.name = dict["name"] as String
        var reps:[String] = []
        
        if let car = dict["car"] as? [String:AnyObject] {
            self.carName = car["name"] as? String
            if let rep = car["repairs"] as? [String] {
                reps = rep
            }
        }
        self.repairs = reps
        
        let friends = dict["friends"] as [AnyObject]
        self.firstFriend = friends[0]["name"] as String
    }
    
    
}

struct Decoder {
    
    let notAnArrayError = NSError(domain: "com.optionreader", code: 2, userInfo: [ "message" : "data is not array like" ])
    let notADictionaryError = NSError(domain: "com.optionreader", code: 3, userInfo: [ "message" : "data is not dictionary like" ])
    
    
    private var rawDictionary: [String : AnyObject]?
    private var rawArray: [AnyObject]?
    private var value: AnyObject?
    private var error: NSError?
    let depth: Int
    
    init(dictionary: [String : AnyObject], depth: Int = 0) {
        self.rawDictionary = dictionary
        self.depth = depth
    }
    
    init(array: [AnyObject], depth: Int = 0) {
        self.rawArray = array
        self.depth = depth
    }
    
    init(value: AnyObject, parseType: Bool = false, depth: Int = 0) {
        self.depth = depth
        if !parseType {
            self.value = value
        }
        else {
            if let a = value as? [AnyObject] {
                self.rawArray = a
            }
            else if let d = val as? [String : AnyObject] {
                self.rawDictionary = d
            }
            else {
                self.value = value
            }
        }
    }
    
    private init(error: NSError, depth: Int = 0) {
        self.depth = depth
        self.error = error
    }
    
    var arr: DecoderArray? {
        if let a = rawArray {
            return DecoderArray(items: a)
        }
        else {
            return nil
        }
    }
    
    var dict: DecoderDictionary? {
        if let a = rawDictionary {
            return DecoderDictionary(items: a)
        }
        else {
            return nil
        }
    }
    
    var val: AnyObject? {
        return self.value
    }
    
    var err: NSError? {
        return self.error
    }
    
    
    private func indexOutRangeError(index: Int) -> NSError {
        return NSError(domain: "com.optionreader", code: 1, userInfo: [ "message" : "index \(index) of range of array at depth \(self.depth)" ])
    }
    
    private func keyNotPresentError(key: String) -> NSError {
        return NSError(domain: "com.optionreader", code: 1, userInfo: [ "message" : "key '\(key)' not present in dictionary at depth \(self.depth)" ])
    }
    
    subscript(index: Int) -> Decoder {
        if let e = error {
            return Decoder(error: e)
        }
        else {
            if let a = rawArray {
                if index >= a.count {
                    return Decoder(error: indexOutRangeError(index), depth : depth + 1)
                }
                else {
                    return mapToData(a[index])
                }
            }
            else {
                return Decoder(error: notAnArrayError)
            }
        }
    }
    
    subscript(key: String) -> Decoder {
        if let d = rawDictionary {
            if let val: AnyObject = d[key] {
                return mapToData(val)
            }
            else {
                return Decoder(error: keyNotPresentError(key), depth : depth + 1)
            }
        }
        else {
            return Decoder(error: keyNotPresentError(key), depth : depth + 1)
        }
    }
    
    func mapToData(val: AnyObject) -> Decoder {
        if let a = val as? [AnyObject] {
            return Decoder(array: a, depth : depth + 1)
        }
        else if let d = val as? [String : AnyObject] {
            return Decoder(dictionary: d, depth : depth + 1)
        }
        else {
            return Decoder(value: val, depth : depth + 1)
        }
    }
    
}

struct DecoderArray : SequenceType {
    
    let items: [AnyObject]
    
    func generate() -> GeneratorOf<Decoder> {
        
        var i = -1
        
        return GeneratorOf<Decoder> {
            i++
            if( i < self.items.count) {
                return Decoder(value: self.items[i], parseType: true)
            }
            else {
                return nil
            }
        }
    }
    
    
}

struct DecoderDictionary : SequenceType {
    
    let items: [String: AnyObject]
    
    func generate() -> GeneratorOf<(String, Decoder)> {
        
        var i = -1
        let keys = items.keys.array
        
        return GeneratorOf<(String, Decoder)> {
            i++
            if( i < self.items.count) {
                let key = keys[i]
                let value =  Decoder(value: self.items[key]!, parseType: true)
                return (key, value)
            }
            else {
                return nil
            }
        }
    }
    
    
}

let bob: [String:AnyObject] =
[
    "name" : "Bob",
    "scheduleDays" : [2, 4, 5, 4],
    "friends" : [
        [ "name" : "Chelsey", "age" : 10 ],
        [ "name" : "Eric", "age" : 11 ]
    ],
    "car" : [
        "name" : "Honda",
        "repairs" : ["oil", "brakes"]
    ]
]

let susie: [String:AnyObject] =
[
    "name" : "Susie",
    "scheduleDays" : [2, 3, 6, 4],
    "friends" : [
        [ "name" : "Eric", "age" : 10 ],
        [ "name" : "Chelsey", "age" : 11 ]
    ]
]

let kenny: [String:AnyObject] =
[
    "name" : "Kenny",
    "scheduleDays" : [2, 4, 5, 4],
    "friends" : [
        [ "name" : "Eric", "age" : 11 ],
        [ "name" : "Chelsey", "age" : 10 ]
    ],
    "car" : [
        "name" : "Ford"
    ]
]



let bobDict = Decoder(dictionary: bob)
let susieDict = Decoder(dictionary: susie)
let kennyDict = Decoder(dictionary: kenny)

let bobPerson = Person(decoder: bobDict)
let susiePerson = Person(decoder: susieDict)
let kennyPerson = Person(decoder: kennyDict)

let kennyFromDict = Person(dict: kenny)

bobPerson?.repairs