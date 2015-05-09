
object pepita {
	var energia = 100
	var ubicacion = 0
	
	method energia() { 
		return energia
	}
	
	method volar(km) {
		energia -= (2 * km) + 10
	}
	
	method comer(comida) {
		energia += comida.energia()
	}
	
	method ubicacion() {
		return ubicacion
	}
	
	method volarA(lugar) {
		energia -= ubicacion - lugar.ubicacion()
		ubicacion = lugar.ubicacion()
	} 
	
	method puedeIrA(lugar) {

	}
	
}

object alpiste {
	val energia = 10
	
	method energia() {
		return energia
	}
}

object pepona {
	var energia = 50
	
	method comer(comida) {
		energia += comida.energia()
	}
	
	method energia() {
		return energia
	}
}

object otraPepita {
	var energia = 0
	
	method comer(comida) {
		energia += comida.energia()
	}
	
	method energia() {
		return energia
	}
	
}

object golondrina1 {
	var energia = 0
	
	method comer(comida) {
		energia += comida.energia()
	}
	
	method energia() {
		return energia
	}
	
}


