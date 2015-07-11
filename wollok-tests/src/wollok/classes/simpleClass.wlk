/**
 * A package for sarasa
 * 
 * @author jfernandes
 */
class Golondrina {
	var energia = 100 /** Retorna la energia actual  */
	method getEnergia() {
		energia
	}

	/** Setea la energia */
	method setEnergia(e) {
		energia = e
	}

	/** Hace que vuele */
	method volar(kms) {
		energia -= kms
	}
}

