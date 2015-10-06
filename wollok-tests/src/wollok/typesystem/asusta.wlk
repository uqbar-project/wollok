class Asustador {
	var edad = 0
	var nivelMotivacion = 100
	
	method getEdad() = edad
	method setEdad(e) { edad = e }
	
	method getNivelMotivacion() = nivelMotivacion
	
	method entrarAPuerta(puerta) {
		puerta.entra(this)
	}
	method asustar(ninio) = (nivelMotivacion / 100) * (this.puntosDeTerror() / ninio.getEdad())
	
	method puntosDeTerror()
	
	method reducirMotivacion(cuantoPorciento) {
		val reduc = cuantoPorciento * nivelMotivacion 
		nivelMotivacion = nivelMotivacion - reduc
	}
}

class AsustadorNato extends Asustador {
	var puntosTerrorInnatos
	new (p) { puntosTerrorInnatos = p	}
	override method puntosDeTerror() = puntosTerrorInnatos * this.getEdad()
}

