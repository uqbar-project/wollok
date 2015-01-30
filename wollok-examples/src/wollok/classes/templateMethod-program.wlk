import templateMethod.*

program templateMethod {
	
	val pepita = new Golondrina()
	pepita.volar(50)
	this.assert(pepita.energia() == 50) // Mismo comportamiento de siempre
	
	val pepona = new NoSeCansa()
	pepona.volar(50)
	this.assert(pepona.energia() == 100) // Mantiene energía inicial
	
}