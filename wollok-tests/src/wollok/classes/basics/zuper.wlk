package zuper {

class Golondrina {
	var energia = 100

	method energia() = energia

	method volar(kms) {
		energia = energia - self.gastoParaVolar(kms) // Invocacion a método que se va a sobreescribir
	}  
	
	method gastoParaVolar(kms) = kms
	
	method blah(a) {
		self.gastoParaVolar(a)
		// super(a) // FAIL OK !
	}
}

class SeCansaMucho inherits Golondrina {
	override method gastoParaVolar(kms) {
		const r = super(kms)
		return 2 * r
	}
}

}