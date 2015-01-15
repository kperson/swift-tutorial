// Playground - noun: a place where people can play

import UIKit

extension OptionReader {

    var string: String? {
        return self.value as? String
    }
    
    var int: Int? {
        return self.value as? Int
    }
    
    var double: Double? {
        return self.value as? Double
    }
    
    var float: Float? {
        return self.value as? Float
    }
    
    var errorMessage: String? {
        if let err = self.error as NSError? {
            return err.userInfo!["message"] as String?
        }
        return nil
    }
    
}

class OptionReader {
    
    let notAnArrayError = NSError(domain: "com.optionreader", code: 2, userInfo: [ "message" : "data is not array like" ])
    let notADictionaryError = NSError(domain: "com.optionreader", code: 3, userInfo: [ "message" : "data is not dictionary like" ])

    
    var dictionary: [String : AnyObject]?
    var array: [AnyObject]?
    var value: AnyObject?
    var error: NSError?
    
    
    init(dictionary: [String : AnyObject]) {
        self.dictionary = dictionary
    }
    init(array: [AnyObject]) {
        self.array = array
    }
    
    init(value: AnyObject) {
        self.value = value
    }
    
    init(error: NSError) {
        self.error = error
    }
    
    func indexOutRangeError(index: Int) -> NSError {
        return NSError(domain: "com.optionreader", code: 1, userInfo: [ "message" : "index \(index) of range" ])
    }
    
    func keyNotPresentError(key: String) -> NSError {
        return NSError(domain: "com.optionreader", code: 1, userInfo: [ "message" : "key \(key) not present" ])
    }
    
    subscript(index: Int) -> OptionReader {
        if let e = error {
            return OptionReader(error: e)
        }
        else {
            if let a = array {
                if index >= a.count {
                    return OptionReader(error: indexOutRangeError(index))
                }
                else {
                    return mapToData(a[index])
                }
            }
            else {
                return OptionReader(error: notAnArrayError)
            }
        }
    }
    
    subscript(key: String) -> OptionReader {
        if let d = dictionary {
            if let val: AnyObject = d[key] {
                return mapToData(val)
            }
            else {
                return OptionReader(error: keyNotPresentError(key))
            }
        }
        else {
            return OptionReader(error: notADictionaryError)
        }
    }
    
    func mapToData(val: AnyObject) -> OptionReader {
        if let arr = val as? [AnyObject] {
            return OptionReader(array: arr)
        }
        else if let dict = val as? [String : AnyObject] {
            return OptionReader(dictionary: dict)
        }
        else {
            return OptionReader(value: val)
        }
    }
    
}


let bob: [String:AnyObject] =
[
    "name" : "Bob",
    "scheduleDays" : [2, 4, 5, 4],
    "friends" : [
        [ "name" : "Eric", "age" : 11 ],
        [ "name" : "Chelsey", "age" : 10 ]
    ],
    "car" : "Honda"
]

let susie: [String:AnyObject] =
[
    "name" : "Susie",
    "scheduleDays" : [2, 4, 5, 4],
    "friends" : [
        [ "name" : "Eric", "age" : 11 ],
        [ "name" : "Chelsey", "age" : 10 ]
    ]
]

let dataDict = OptionReader(dictionary: bob)
let dataArr = OptionReader(array: [bob, susie])


dataArr[0]["car"].string

dataArr[0]["name"].string
dataArr[1]["name"].string

dataArr[2]["name"].errorMessage

dataDict["name"].string

let arr = dataArr.array!



