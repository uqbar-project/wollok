package constructorsLib {
	
class Direccion {
	var calle = ""
	var numero = 0
	val a
	
	new(c, n) {
		calle = c
		numero = n
		a = 23
	}
	
	new (c) = this(c, 3) {
		// ...
	}
	
	method getCalle() { calle }
	method getNumero() { numero }
}
	
	
//	new Direccion { calle = "Humberto 1mo", numero = 1080, a = 23 }
	
}