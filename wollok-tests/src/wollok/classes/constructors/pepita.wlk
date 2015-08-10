object pepita {
	var energia = 100
	
	method energia() { 
		return energia
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
		return 5
	}
}

object hamburguesa {
	method energia() {
		return 800
	}
}

