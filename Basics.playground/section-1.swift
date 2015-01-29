import UIKit

/*
    var vs. let
*/

// let keyword defines a constant
let answer = 83
//answer = 101        // Error: Cannot assign to 'let' value 'answer'

// var defines an ordinary variable, that you would expect to set again
var dayOfMonth = 25
dayOfMonth = 27


var apple = "Apple"
apple = "Granny Smith " + apple
let granny = apple


struct example {
    var i:Int = 0
    
    // structs and enums are value types
    mutating func plusOne() {
        i = i++
    }
    func print() {
        println(i)
    }
}

var x = example()
x.print()  // If a let, error: Immutable value of type 'example' only has mutating members named 'plusOne'
x.plusOne()

class Painting {
    var name:String
    
    init (name:String) {
        self.name = name
    }
}

let myPainting = Painting(name: "Mona Lisa")
myPainting.name = "Starry Night"    // even though myPainting is defined as a let, I am allowed to change vars within my class


let someInt = 5
let someIntAsDouble = Double(someInt)   // This is NOT a cast - creating a Double from an Int

///////////////////////////////////////////////////////////////////////////////////

/*
    Designated and Convenience Initializers
*/

class Employee {
    let name : String
    var hometown : String
    
    // Designated Initializer
    init (name:String, hometown:String) {
        println("In superclass before property init")
        self.name = name
        self.hometown = hometown
        println("In superclass after property init")
    }
    
     convenience init (name: String) {
        self.init(name:name, hometown:"Chicago")
    }
}

extension NSURL {
    convenience init?(path:String) {    // Failable initializer
        self.init(string: "http://www.google.com/" + path)
    }
}

let url = NSURL(path: "images")

class Developer : Employee {
    var currentProject : String
    
    // Two Stage Initialization
    init(name: String, hometown: String, currentProject: String) {
        println("In subclass before project init")
        self.currentProject = currentProject
        println("In subclass after project init")
        super.init(name: name, hometown: hometown)
        println("In subclass after super init")
    }
}

let peter = Employee(name: "Peter")

// Can't init a subclass using the super class' convenience initializer

let chelsea = Developer(name: "Chelsea", hometown:"Dallas" , currentProject: "Discover")

/* Console Output

In superclass before property init
In superclass after property init
In subclass before project init
In subclass after project init
In superclass before property init
In superclass after property init
In subclass after super init

*/

///////////////////////////////////////////////////////////////////////////////////

/*
    Tuples
*/

//Unnamed Tuples

let tipAndTotal = (4.00, 25.19)

// Can also specify with the data types
let tipAndTotalBill:(Double, Double) = (3.00, 33.25)

// Accessing tuple elements
tipAndTotal.0
tipAndTotal.1

let (tip, total) = tipAndTotal
tip
total

// Named Tuples

// Can mix data types in tuples
let steven = (nickname: "Steve", age: 34)
steven.nickname
steven.1

// Function Returning Tuples

let billTotal = 26.02
let taxPercentage = 0.07
let subtotal = total / (1 + taxPercentage)

// Alternative method name:
// func calculateTipWithTipPercentage(Double) -> (Double, Double)
func calculateTipWithTipPercentage(tipPercentage:Double) -> (tipAmount: Double, finalTotal: Double) {
    let tipAmount = subtotal * tipPercentage // Tip amount based on bill total (before tax)
    let finalTotal = billTotal + tipAmount
    return (tipAmount, finalTotal)
}

calculateTipWithTipPercentage(0.2)

///////////////////////////////////////////////////////////////////////////////////

/*
    Generics
*/


func swapTwoValues<T>(inout a: T, inout b: T) {
    let temporaryA = a
    a = b
    b = temporaryA
}

struct myStruct<T: Hashable> {
    var myDictionary: Dictionary<T, Int>
}
