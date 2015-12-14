class Asustable {
	method teVaAAsustar(asustador)
}

class Ninio inherits Asustable {
	var edad = 0
	
	new(e) { edad = e }
	method setEdad(e) { edad = e }
	method getEdad() = edad
	override method teVaAAsustar(asustador) {
		return asustador.asustar(this)
	}
}

class Piyamada inherits Asustable {
	var ninios = #[]
	method agregarNinio(n) { ninios.add(n) }
	override method teVaAAsustar(asustador) {
		return ninios.fold(0, [a, n| 
			a + asustador.asustar(n)
		])
	}
}

class Adulto inherits Asustable {
}

class Adolescente inherits Asustable {
	override method teVaAAsustar(asustador) {
		var factor = 0.10
		asustador.reducirMotivacion(factor)
		return 0
	}
}
