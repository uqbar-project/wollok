class Actividad {
	method calcularMejora()
}

class EstudiarMateria inherits Actividad {
	var materia
	var puntos = 0
	
	constructor(m, p) {
		materia = m
		puntos = p
	}
	
	override method calcularMejora() = puntos
}

class EjercitarEnSimulador inherits Actividad {
	var horas = 0
	constructor(h) { horas = h }
	override method calcularMejora() = 10 * horas
}