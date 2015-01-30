
class AsistenteNormal {
	method calcularEnergia(energia) { energia }
}

class AsistenteIneficiente {
	var reduce = 0
	new(cuanto) { reduce = cuanto }
	method calcularEnergia(energia) { energia - reduce }
}

class AsistenteSupereficiente {
	var factor
	new(f) { factor = f }
	method calcularEnergia(energia) { energia * (1 + factor)}
}