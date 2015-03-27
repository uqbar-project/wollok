program variablesAndNumbers {

// values
val a = 23
val b = a + 1

//val y = a + "23"

//b = 23 //CANNOT MODIFY VALUES!

// variables
var c = 23
c = 24   //OK!

/*
 * asdasd
 */

this.assert(b == 24)

this.assert(10 - 5 == 5)
this.assert(10 * a == 230)
this.assert(100 / 10 == 10)
this.assert(100 % 10 == 0)
this.assert(2 ** 3 == 8.0)
this.assertEquals(8.0, 2**3)

this.assert(2 * 2.0 == 2.0 * 2)
this.assert(2 + 2.0 == 2.0 + 2)

this.assert("Hola" * 3 == "HolaHolaHola")
this.assert(3 * "Hola" == "HolaHolaHola")

this.assertEquals(0 - 1, -1)
this.assertEquals(0 - 4, -4)

this.assert("Hola Mundo" - 6 == "Hola")
this.assert("Juan Jose Juan Pepe" - "Juan" == " Jose  Pepe")

var d = 1
d++
this.assertEquals(2, d)

d--
this.assertEquals(1, d)

d += 3
this.assertEquals(4, d)

d -= 1
this.assertEquals(3, d)

d *= 2
this.assertEquals(6, d)

}