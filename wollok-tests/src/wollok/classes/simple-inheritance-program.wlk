import simpleInheritance.*

program simpleInheritance {
	
	val pepita = new Golondrina()
	pepita.volar(50)

	pepita.setEnergia(23)

	this.assert(pepita.energia() == 50) // Mando mensaje en superclase
	
}