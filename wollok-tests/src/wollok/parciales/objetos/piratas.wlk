
object barcoPirata {
	var mision = buscarTesoro
	var capacidad = 50
	var tripulacion = 42
	var ancla
	
	method getAncla() = ancla
		
	method tieneSuficienteTripulacion() {
		return tripulacion >= capacidad * 0.9 
	}
}

object barcoPirata2 {
	var mision = saquear
	var capacidad = 50
	var tripulacion = 42
	
	method cambiarMision(nuevaMision) {
		mision = nuevaMision
	}
	
	method tieneSuficienteTripulacion() {
		return tripulacion >= capacidad * 0.9 
	}
} 


object barbanegra {
	var items = #["brujula", "cuchillo", "cuchillo", "dienteDeOro", "grodXD", "grodXD", "grodXD"]
	var nivelEbriedad = 50
	var dinero = 10
	
	method esUtilParaUnaMision(mision) {
		return mision.puedeSerCumplidaPor(this)
	}
	
	method items() {
		return items
	}
	
	method getDinero() {
		return dinero
	}
}

class A {
	new(p) {}
	new(a, b) {}
	new(a, b, c) {}
}

class B extends A {
}

object jack {
	var items = #["brujula", "cuchillo", "cuchillo", "dienteDeOro", "grodXD", "grodXD", "grodXD"]
	var nivelEbriedad = 50
	var dinero = 2
	
	method esUtilParaUnaMision(mision) {
		return mision.puedeSerCumplidaPor(this)
	}
	
	method items() {
		return items
	}
	
	method getDinero() {
		return dinero
	}
}

object buscarTesoro {
	method puedeSerCumplidaPor(pirata) {
		return (pirata.items().contains("brujula") 
			|| pirata.items().contains("mapa") || pirata.items().contains("mapa")
		) && (pirata.getDinero() <= 5)
	}
}

object serLeyenda {
	var itemObligatorio = "dienteDeOro"
	
	method puedeSerCumplidaPor(pirata) {
		return pirata.items().size() == 7 && pirata.items().contains(itemObligatorio)
	}
	
}

object saquear {
	var victima = barcoPirata
	var saqueador = barcoPirata2
	var cantidadDeDineroMaxima = 5
	
	method puedeSerCumplidaPor(pirata) {
		return pirata.getDinero() < cantidadDeDineroMaxima && victima.esVulnerablePara(pirata)
	}
	
}
