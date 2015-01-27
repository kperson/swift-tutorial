// Playground - noun: a place where people can play

import UIKit

//*************************************

func sayHello() -> Void {
    println("hello")
}

func sayGoodbye() -> Void {
    println("goodbye")
}

func speak(speakFunction: () ->Void) {
    speakFunction()
}

speak(sayHello)
speak(sayGoodbye)

let y: () -> Void = {
    println("hi")
}

speak(y)

//*************************************
//Old way
let numbersArray = [2,4,6,8]

var mapArray:[String] = []

for money  in numbersArray {
    mapArray.append("$\(money).00")
}
println(mapArray)

//New way
mapArray = numbersArray.map({ "$\($0).00" })
println(mapArray)

//**************************************
//Old way
var sum = 0
for money  in numbersArray {
    sum += money
}
println(sum)

//New Way
sum = numbersArray.reduce(0, {$0 + $1})
println(sum)

//**************************************
//Old way
var oldFilteredNumbers:[Int] = []

for money  in numbersArray {
    if money % 3 == 0 {
        oldFilteredNumbers.append(money)
    }
}
println(oldFilteredNumbers)

//New way
let filteredNumbers = numbersArray.filter({$0 % 3 == 0})

println(filteredNumbers)

//**************************************
//Chaining
let filterAndMappedValues = numbersArray.filter({$0 % 3 == 0}).map({ "$\($0).00" })
print(filterAndMappedValues)

