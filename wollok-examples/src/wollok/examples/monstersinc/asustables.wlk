package asustables {

	class Asustable {
		method teVaAAsustar(asustador)
	}
	
	class Ninio extends Asustable {
		var edad = 0
		
		new(e) { edad = e }
		method setEdad(e) { edad = e }
		method getEdad() { edad }
		override method teVaAAsustar(asustador) {
			asustador.asustar(this)
		}
	}
	
	class Piyamada extends Asustable {
		var ninios = #[]
		method agregarNinio(n) { ninios.add(n) }
		override method teVaAAsustar(asustador) {
			ninios.fold(0, [a, n| 
				a + asustador.asustar(n)
			])
		}
	}
	
	class Adulto extends Asustable {
	}
	
	class Adolescente extends Asustable {
		override method teVaAAsustar(asustador) {
			asustador.reducirMotivacion(0.10)
			0
		}
	}

}