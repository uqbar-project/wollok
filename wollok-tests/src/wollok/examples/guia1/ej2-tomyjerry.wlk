object tom {
	var energia = 100
	
	method comer(raton) {
		energia += this.energiaPorComer(raton)
	}
	
	method energiaPorComer(raton) {
		return 12 + raton.peso()
	}
	
	method correr(segundos) {
		this.correrDistancia(this.metrosQueCorreEn(segundos))
	}
	
	method correrDistancia(metros) {
		energia -= this.energiaPorCorrer(metros)
	}
	
	method energiaPorCorrer(metros) {
		return 0.5 * metros
	}
	
	method metrosQueCorreEn(segundos) {
		return this.velocidad() * segundos
	}
	
	method velocidad() {
		return 5 + (energia / 10)
	}
	
	method meConvieneComerA(raton, metros) {
		return this.energiaPorComer(raton) > this.energiaPorCorrer(metros)
	}
}

object raton {
	var peso = 30
	
	method peso() {
		peso
	}
}