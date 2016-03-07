
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
	
	method ubicacion() = ubicacion
	
	method volarA(lugar) {
		energia -= ubicacion - lugar.ubicacion()
		ubicacion = lugar.ubicacion()
	} 
	
	method puedeIrA(lugar) {

	}
	
}

object alpiste {
	const energia = 10
	
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


object pajarera {
	
	const pajaros = [pepita, pepona, otraPepita]
	
	method cuantosHay() {
		return pajaros.size()
	}	
	
	method agregar(pajaro) {
		pajaros.add(pajaro)
	}
	
	method sacar(pajaro) {
		pajaros.remove(pajaro)
	}

	method alimentarATodosCon(alpiste) {
		pajaros.forEach{p => p.comer(alpiste)}
	}
 	
 	method sonTodosSaludables() {
 		var suma = pajaros.sum{p => p.energia()}
 		return suma
 	}
 	
 	method alimentarALaPeor() {
 		return pajaros.min{p => p.energia()}
 	
 	}
}


