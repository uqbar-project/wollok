object tom {
	var energia = 100
	
	method comer(raton) {
		energia += self.energiaPorComer(raton)
	}
	
	method energiaPorComer(raton) {
		return 12 + raton.peso()
	}
	
	method correr(segundos) {
		self.correrDistancia(self.metrosQueCorreEn(segundos))
	}
	
	method correrDistancia(metros) {
		energia -= self.energiaPorCorrer(metros)
	}
	
	method energiaPorCorrer(metros) {
		return 0.5 * metros
	}
	
	method metrosQueCorreEn(segundos) {
		return self.velocidad() * segundos
	}
	
	method velocidad() {
		return 5 + (energia / 10)
	}
	
	method meConvieneComerA(raton, metros) {
		return self.energiaPorComer(raton) > self.energiaPorCorrer(metros)
	}
}

object raton {
	var peso = 30
	
	method peso() = peso
}