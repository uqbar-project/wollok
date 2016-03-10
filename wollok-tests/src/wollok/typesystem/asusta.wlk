class Asustador {
	var edad = 0
	var nivelMotivacion = 100
	
	method getEdad() = edad
	method setEdad(e) { edad = e }
	
	method getNivelMotivacion() = nivelMotivacion
	
	method entrarAPuerta(puerta) {
		puerta.entra(self)
	}
	method asustar(ninio) = (nivelMotivacion / 100) * (self.puntosDeTerror() / ninio.getEdad())
	
	method puntosDeTerror()
	
	method reducirMotivacion(cuantoPorciento) {
		const reduc = cuantoPorciento * nivelMotivacion 
		nivelMotivacion = nivelMotivacion - reduc
	}
}

class AsustadorNato inherits Asustador {
	var puntosTerrorInnatos
	constructor (p) { puntosTerrorInnatos = p	}
	override method puntosDeTerror() = puntosTerrorInnatos * self.getEdad()
}

