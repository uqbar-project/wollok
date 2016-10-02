class Golondrina {
	var energia = 100

	method energia() = energia

	method volar(kms) {
		energia = energia - self.gastoParaVolar(kms) // Invocacion a método que se va a sobreescribir
	}
	
	method gastoParaVolar(kms) = kms
}

class NoSeCansa inherits Golondrina {
	override method gastoParaVolar(kms) = 0
}

