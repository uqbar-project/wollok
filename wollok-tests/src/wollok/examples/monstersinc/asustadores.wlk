class Asustador {
	var edad = 0
	var nivelMotivacion = 100
	
	constructor(e) { edad = e }
	method getEdad() = edad  
	method setEdad(e) { edad = e }
	
	method getNivelMotivacion() = nivelMotivacion
	
	method entrarAPuerta(puerta) {
		return puerta.entra(this)
	}
	
	method asustar(ninio) {
		const a = this.getPorcentaje()
		return a * this.puntosDeTerror() / ninio.getEdad()
	}
	method getPorcentaje() {
		return nivelMotivacion / 100
	}
	
	method puntosDeTerror()
	
	method reducirMotivacion(cuantoPorciento) {
		nivelMotivacion -= cuantoPorciento * nivelMotivacion
	}
}

class AsustadorNato inherits Asustador {
	var puntosTerrorInnatos
	constructor(e, p) = super(e) { 
		puntosTerrorInnatos = p
	}
	override method puntosDeTerror() {
		return puntosTerrorInnatos * this.getEdad()
	}
}

class AsustadorPerseverante inherits Asustador {
	var puntosDeTerror = 0
	
	constructor(e) = super(e)
	
	method mejora(actividad) {
		puntosDeTerror += actividad.calcularMejora()
	}
	override method puntosDeTerror() = puntosDeTerror
}

