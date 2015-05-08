object pepe { 
	var categoria 
	var faltas 
	var bonoproductividad = true 
	var productividad = 50 
	method sueldobase() {
		return categoria.sueldobase(faltas)
	}
	method setcategoria(nuevacategoria) {
		categoria = nuevacategoria
	}
	method setfaltas(unafalta) {
		faltas = unafalta
	}
	method sueldo() {
		if (bonoproductividad) {
			return this.sueldobase() * (1 + this.bono())
		}
		else {
			return this.sueldobase()
		}
	}
	method bono() {
		if (productividad == 50) {
			return 0.25
		}
		else if (productividad >= 50) {
			return 0.1
		}
		else {
			return 0
		}
	}
}

object catGerente { 
	method sueldobase(faltas) {
		return 2500
	}
}

object cadete { 
	method sueldobase(faltas) {
		if (faltas == 0) {
			return 2300 + 500
		}
		else {
			return 2300
		}
	}
}

