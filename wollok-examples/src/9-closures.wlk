program closures {
// 1 param
val incrementClosure = [param | param + 1]
this.assert(incrementClosure.apply(2) == 3)

// 2 params
val addition = [a, b | a + b]
this.assert(addition.apply(10, 15) == 25)


// using outside context VALUE
val n1 = 2
val multiplyByN1 = [i| i * n1]

this.assert(multiplyByN1.apply(3) == 6)


// using outside context VARIABLE (mutating)
var n2 = 2
val multiplyByN2 = [i| i * n2]
n2 = 10

this.assertEquals(30,multiplyByN2.apply(3))
 
}