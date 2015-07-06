class MonstersInc {
	var equipos = #[]
	var puertas = #[]

	method getEquipos() { equipos }	
	method agregarPuerta(p) { puertas.add(p) }
	method agregarEquipo(e) { equipos.add(e) }
	method removerEquipo(e) { equipos.remove(e) }
	method getEnergiaTotalGenerada() {
		equipos.sum([e| e.getEnergiaGenerada()])
	}
	
	method diaLaboral() {
		equipos.forEach([e| e.visitar(puertas.any())])
	}
	
	method equipoMasAsustador() {
		equipos.max([e| e.getEnergiaGenerada()])
	} 
}

class Puerta {
	var contenido
	new(c) { contenido = c }
	method entra(asustador) { 
		contenido.teVaAAsustar(asustador)
	}
}

class Equipo {
	var asustador
	var asistente
	var energiaGenerada = 0
	new(asus, asis) { 
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
	method getEnergiaGenerada() { energiaGenerada }
	method nuevoDia() { energiaGenerada = 0 }
}

