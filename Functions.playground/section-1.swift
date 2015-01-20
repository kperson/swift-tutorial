// Playground - noun: a place where people can play

import UIKit

//*************************************

//func sayHello() {
//    println("hello")
//}
//
//func sayGoodbye() {
//    println("goodbye")
//}
//
//func speak(speakFunction: ()) {
//    speakFunction
//}
//
//speak(sayHello())
//speak(sayGoodbye())


//*************************************

let numbersArray = [2,4,6,8]

var mapArray:[String] = []

for money  in numbersArray {
    mapArray.append("$\(money).00")
}

println(mapArray)

mapArray = numbersArray.map({ "$\($0).00" })
println(mapArray)

//**************************************

var sum = 0
for money  in numbersArray {
    sum += money
}
println(sum)

sum = numbersArray.reduce(0, {$0 + $1})
println(sum)

//**************************************

var oldFilteredNumbers:[Int] = []

for money  in numbersArray {
    if money % 3 == 0 {
        oldFilteredNumbers.append(money)
    }
}

println(oldFilteredNumbers)

let filteredNumbers = numbersArray.filter({$0 % 3 == 0})

println(filteredNumbers)

//**************************************

let filterAndMappedValues = numbersArray.filter({$0 % 3 == 0}).map({ "$\($0).00" })
print(filterAndMappedValues)

