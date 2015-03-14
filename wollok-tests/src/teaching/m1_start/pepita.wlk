object pepita {
	var energia = 100
	
	method energia() { 
		energia
	}
	
	method volar(metros) {
		energia -= metros * 4
	}
	
	method comer(algo) {
		energia += algo.energia()
	}
}

object alpiste {
	method energia() {
		5
	}
}

object hamburguesa {
	method energia() {
		800
	}
}

