class Actividad {
	method calcularMejora()
}

class EstudiarMateria extends Actividad {
	var materia
	var puntos = 0
	
	new(m, p) {
		materia = m
		puntos = p
	}
	
	override method calcularMejora() { return puntos }
}

class EjercitarEnSimulador extends Actividad {
	var horas = 0
	new(h) { horas = h }
	override method calcularMejora() { return 10 * horas }
}