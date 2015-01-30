program objectLiterals {

var pepita = object {
	var energia = 120
	
	method comer(cuanto) {
		energia = energia + cuanto
	}
	method energia() {
		energia
	}
	method algoConPerro(perro) {
		perro.ladrar()
		perro.ladrar() // autocompletado
		perro.saltar()
	}
}

pepita.comer(5)
this.assert(pepita.energia() == 125)

// assignments to check type system
//pepita = 23 // FAIL (OK)

pepita = object {
	method comer(cuanto) {}
	method energia() {}
	method algoConPerro(p) {
		p.echate()
	}
}

}