// Playground - noun: a place where people can play

//Topics - Infix Operators, Generics, Recursion, Composition

import UIKit

public enum Try<T> {
    case Success(@autoclosure() -> T)
    case Failure(NSError)
    
    public var error: NSError? {
        switch self {
        case .Failure(let err): return err
        default: return nil
        }
    }
    
    public var value: T? {
        switch self {
        case .Success(let val): return val()
        default: return nil
        }
    }
}

class Validation<T> {

    let f: (T, Validation<T>) -> Void
    
    private var parent: Validation<T>?
    private var child: Validation<T>?
    
    var errorMessage: String?
    
    init(f: (T, Validation<T>) -> Void) {
        self.f = f
    }
    
    func check(assertion: @autoclosure() -> Bool, _ message: String) {
        if errorMessage == Optional.None {
            if(!assertion()) {
                errorMessage = message
            }
        }
    }
    
    func and(v: Validation<T>) -> Validation<T> {
        child = v
        child?.parent = self
        return v
    }
    
    func or(v: Validation<T>) -> Validation<T> {
        return Validation<T> { (value, checker) in
            if let err = self.checkForError(value) {
                if let orError = v.checkForError(value) {
                    checker.errorMessage = "'\(err)' or '\(orError)'"
                }
            }
        }
    }
    
    func validate(value: T) -> String? {
        return self.root.runLocalValidate(value)
    }
    
    
    func runLocalValidate(value: T) -> String? {
        if let error = checkForError(value) {
            return error
        }
        else if let c = child {
            return c.runLocalValidate(value)
        }
        else {
            return nil
        }
    }
    
    func checkForError(value: T) -> String? {
        f(value, self)
        return errorMessage
    }
    
    private var root: Validation<T> {
        if let p = parent {
            return p.root
        }
        else {
            return self
        }
    }
    
    func map<S>(target: Validation<S>, f: (T) -> S) -> Validation<T> {
        return Validation<T> { (value, checker) in
            let convert = f(value)
            if let err = target.checkForError(convert) {
                checker.errorMessage = err
            }
        }
    }
    
}

/*
//If && and || were not declared infix operators you would need to declar like
infix operator && {
    associativity left
    precedence 155
}
*/
func && <T>(left:Validation<T>, right:Validation<T>) -> Validation<T> {
    return left.and(right)
}


func || <T>(left:Validation<T>, right:Validation<T>) -> Validation<T> {
    return left.or(right)
}


/*
//If ! were not prefix operators you would need to declar like

prefix operator ! {}
*/

prefix func !<T>(validation: Validation<T>) -> Validation<T> {
    return Validation<T> { (value, checker) in
        if validation.checkForError(value) == Optional.None {
            validation.errorMessage = "Error not not found"
        }

    }
}



//Usuage
let validatorOne = Validation<Int> { (num, checker) in
    checker.check(num > 2, "num must be greater than 2")
}

let validatorTwo = Validation<Int> { (num, checker) in
    checker.check(num > 5, "num must be greater than 5")
}


if let err = validatorOne.or(validatorTwo).validate(3) {
    println(err)    //never executes
}

if let err = (validatorOne || validatorTwo).validate(3) {
    println(err)    //never executes
}

if let err = (validatorOne && validatorTwo).validate(10) {
    println(err)    //never executes
}

if let err = (validatorOne && validatorTwo).validate(2) {
    println(err)    //num must be greater than 2
}

if let err = (validatorOne || validatorTwo).validate(3) {
    println(err)    //'num must be greater than' 2 or 'num must be greater than 5'
}

if let err = (!validatorOne && !validatorTwo).validate(2) {
    println(err) // Never executes
}