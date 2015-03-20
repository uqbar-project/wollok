
object pepita {
	var energia = 100
	var ubicacion = 0
	
	method energia() { 
		energia
	}
	
	method volar(km) {
		energia -= (2 * km) + 10
	}
	
	method comer(comida) {
		energia += 4 * comida.gramos()
	}
	
	method ubicacion() {
		ubicacion
	}
	
	method volarA(lugar) {
		energia -= ubicacion - lugar.ubicacion()
		ubicacion = lugar.ubicacion()
	} 
	
	method puedeIrA(lugar) {

	}
	
}