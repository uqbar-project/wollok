object monstersInc {
	var equipos = []
	var puertas = []

	method getEquipos() = equipos	
	method agregarPuerta(p) { puertas.add(p) }
	method agregarEquipo(e) { equipos.add(e) }
	method removerEquipo(e) { equipos.remove(e) }
	method getEnergiaTotalGenerada() {
		return equipos.sum({e=> e.getEnergiaGenerada()})
	}
	
	method cualquierPuerta() {
		if (puertas.size() > 1) return puertas.any()
		else if (puertas.size() == 1) return puertas.get(0) // Walk around issue #199
		else throw "No hay puertas"
	}
	
	method diaLaboral() {
		equipos.forEach({e=> e.visitar(this.cualquierPuerta())})
	}
	
	method equipoMasAsustador() {
		return equipos.max({e=> e.getEnergiaGenerada()})
	} 
}

class Puerta {
	var contenido
	constructor(c) { contenido = c }

	method entra(asustador) { 
		return contenido.teVaAAsustar(asustador)
	}
}

class Equipo {
	var asustador
	var asistente
	var energiaGenerada = 0

	constructor(asus, asis) { 
		asustador = asus
		asistente = asis
	}

	method setAsistente(a) { 
		asistente = a
	}
	method visitar(puerta) {
		val energiaPorAsustar = energiaGenerada + asustador.entrarAPuerta(puerta)
		energiaGenerada = asistente.calcularEnergia(energiaPorAsustar)
	}
	method getEnergiaGenerada() = energiaGenerada
	method nuevoDia() { energiaGenerada = 0 }
}

