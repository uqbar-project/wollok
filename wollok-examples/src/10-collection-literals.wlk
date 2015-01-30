program collections {

val numbers = #[2, 23, 25]

this.println(numbers)

val y = 23
val z = 2.2

val x = "Hola"
val bag = #[x,y,z]
this.println(bag)

// ***************************
// ** calling native methods
// ***************************

// size (a forwarded message to java.util.List)
this.assertEquals(3, numbers.size())
this.assert(numbers.contains(23))
this.assertFalse(numbers.contains(1))

// forAll
this.assert(#[20, 22, 34].forAll([n | n > 18]))
this.assertFalse(#[20, 22, 34].forAll([n | n > 30]))

// forEach
val vaca1 = object {
	var peso = 1000
	method engordar(cuanto) {
		peso = peso + cuanto
	}
	method peso() {
		peso
	}
}

val vaca2 = object {
	var peso = 1000
	method engordar(cuanto) {
		peso = peso + cuanto
	}
	method peso() {
		peso
	}
}
val vacas = #[vaca1, vaca2]

vacas.forEach[v | v.engordar(2)]
this.assert(vacas.forAll[v | v.peso() == 1002])

// map
val mapped = vacas.map[v | v.peso()]
this.assert(mapped.forAll[p | p == 1002])


// filter
val r = #[10, 20, 30, 40, 50].filter[n| n > 30]
this.assert(r.size() == 2)
this.assert(r.contains(40))
this.assert(r.contains(50))

}