object tom {
	var energia = 100
	
	method comer(raton) {
		energia += this.energiaPorComer(raton)
	}
	
	method energiaPorComer(raton) {
		12 + raton.peso()
	}
	
	method correr(segundos) {
		this.correrDistancia(this.metrosQueCorreEn(segundos))
	}
	
	method correrDistancia(metros) {
		energia -= this.energiaPorCorrer()
	}
	
	method energiaPorCorrer(metros) {
		0.5 * metros
	}
	
	method metrosQueCorreEn(segundos) {
		this.velocidad() * segundos
	}
	
	method velocidad() {
		5 + (energia / 10)
	}
	
	method meConvieneComerA(raton, metros) {
		this.energiaPorComer(raton) > this.energiaPorCorrer(metros)
	}
}

object raton {
	var peso = 30
	
	method peso() {
		peso
	}
}