	class Ave {
		var energia = 100

		method energia( ) = energia
		method setEnergia(newEnergia) {
			energia = newEnergia
		}
	}
	class Golondrina inherits Ave {
		method volar(kms) {
			self.setEnergia(self.energia() - kms) // Uso métodos de la superclase
		}
	}
