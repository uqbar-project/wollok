class Pirata {
	var items = []
	var dinero
	var nivelEbriedad
	
	method getItems() {
		return items
	}
	
	method getDinero() {
		return dinero
	}
	
	method getNivelEbriedad() {
		return nivelEbriedad
	}
}

object buscarTesoro {
	method puedeSerCumplidaPor(pirata) {
		return (pirata.getItems().contains("brujula") || pirata.getItems().contains("mapa") || pirata.getItems().contains("botellaGrosXD")) &&
			(pirata.getDinero() <= 5) && (pirata.getNivelEbriedad() < 3)
	}
}

object serLeyenda {
	var itemObligatorio = "dienteDeOro"
	
	method puedeSerCumplidaPor(pirata) {
		return pirata.getItems().size() == 7 && pirata.getItems().contains(itemObligatorio)
	}
	
}

object saquear {
	//var victima = barcoPirata
	//var saqueador = barcoPirata2
	var cantidadDeDineroMaxima = 5
	
	method puedeSerCumplidaPor(pirata) {
		//return pirata.getDinero() < cantidadDeDineroMaxima && victima.esVulnerablePara(pirata)
	}
}

object main {
	
	var pirata = new Pirata(items = ["brujula", "cuchillo", "cuchillo"])	
	//var barco = new Barco()
	
	method getPirata() {
		return pirata
	}
	
	
}

