// ************
// BOOLEANS
program booleans {
	

val trueB = true
var a = "a"
// a = 1  // FAILS OK!

this.assert(trueB)

this.assert(true)
this.assertFalse(false)

//AND
this.assert(true and true)
this.assert(true && true)

this.assertFalse(true and false)
this.assertFalse(true && false)

this.assertFalse(false && true)
this.assertFalse(false && false)

// or
this.assert(true or true)
this.assert(true || true)

this.assert(true || false)
this.assert(false || true)

this.assertFalse(false or false)
this.assertFalse(false || false)

// not operator

this.assert(not false)
this.assert(!false)

this.assertFalse(not true)
this.assertFalse(!true)

this.assert(not(3>5))
this.assert(!(3>5))

// equals
this.assert(2 == 2)
var n1 = 2
var n2 = 2
this.assert(n1 == n2)
this.assertFalse(2 == 3)

val object1 = object {}
val object2 = object {}
this.assert(object1 == object1)
this.assertFalse(object1 == object2)

// not equals
this.assert(2 != 3)

//// >, >=, <, <=
this.assert(2 < 3)
this.assert(2 <= 3)
this.assert(2 <= 2)

this.assert(3 > 2)
this.assert(3 >= 1)
this.assert(3 >= 3)


// **************************
// ** errores de tipos (PASAR A UN XPect)
// **************************

//val unN = 2
//val otroN = 4
//
//val unoYotro = unN && otroN
//val otraComp = true && otroN
//
//val compValida = true && false
//this.println(compValida)

}