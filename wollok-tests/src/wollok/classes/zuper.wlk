package zuper {

class Golondrina {
	var energia = 100

	method energia() = energia

	method volar(kms) {
		energia = energia - this.gastoParaVolar(kms) // Invocacion a método que se va a sobreescribir
	}  
	
	method gastoParaVolar(kms) = kms
	
	method blah(a) = {
		this.gastoParaVolar(a)
		// super(a) // FAIL OK !
	}
}

class SeCansaMucho inherits Golondrina {
	override method gastoParaVolar(kms) {
		val r = super(kms)
		return 2 * r
	}
}

}