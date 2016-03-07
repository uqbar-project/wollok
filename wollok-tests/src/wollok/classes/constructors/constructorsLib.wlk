class Direccion {
	var calle = ""
	var numero = 0
	const a
	
	constructor(c, n) {
		calle = c
		numero = n
		a = 23
	}
	
	constructor (c) = this(c, 3) {
		// ...
	}
	
	method getCalle() { return calle }
	method getNumero() { return numero }
}
	
	
//	new Direccion { calle = "Humberto 1mo", numero = 1080, a = 23 }
	
