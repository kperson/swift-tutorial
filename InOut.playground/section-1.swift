//InOut Examples

func plusOne(inout number: Int) {
    
    number = number + 1
    
}

var x = 3
plusOne(&x)

println(x)                                  //Print 4



/* 
let y = 3
plusOne(&y)

The above will not compile.
Why? The plus one function 
you can not mutate vals (constants)
*/


//What about object types
class MyObj  {
    
    var x: Int = 3
    
}

func assign(inout obj: MyObj)  {
    obj = MyObj()
    obj.x = 10
}
var t = MyObj()
assign(&t)

println(t.x)                                //Prints 10



func tryToAssign(var obj: MyObj)  {
    obj = MyObj()
    obj.x = 10
}

var w = MyObj()
tryToAssign(w)
println(w.x)                                //Prints 3