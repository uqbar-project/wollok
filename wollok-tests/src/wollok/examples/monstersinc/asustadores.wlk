class Asustador {
	var edad = 0
	var nivelMotivacion = 100
	
	new(e) { edad = e }
	method getEdad() = edad  
	method setEdad(e) { edad = e }
	
	method getNivelMotivacion() = nivelMotivacion
	
	method entrarAPuerta(puerta) {
		return puerta.entra(this)
	}
	
	method asustar(ninio) {
		val a = nivelMotivacion / 100
		val ptos = this.puntosDeTerror()
		return a * (ptos / ninio.getEdad())
	}
	
	method /*abstract*/ puntosDeTerror()
	
	method reducirMotivacion(cuantoPorciento) {
		nivelMotivacion -= cuantoPorciento * nivelMotivacion
	}
}

class AsustadorNato extends Asustador {
	var puntosTerrorInnatos
	new(e, p) = super(e) { 
		puntosTerrorInnatos = p
	}
	override method puntosDeTerror() {
		return puntosTerrorInnatos * this.getEdad()
	}
}

class AsustadorPerseverante extends Asustador {
	var puntosDeTerror = 0
	
	new(e) = super(e)
	
	method mejora(actividad) {
		puntosDeTerror += actividad.calcularMejora()
	}
	override method puntosDeTerror() = puntosDeTerror
}

