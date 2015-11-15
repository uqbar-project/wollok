object pepe {

	var categoria
	
	method sueldoBase() {
		return categoria.getSueldoBase()
	}
	
	method setCategoria(nuevaCategoria) {
		categoria = nuevaCategoria
	}

}

object categoria {
	method gerente() { return self.categoria(2500) }
	method cadete() { return self.categoria(2700) }
	method jefe() { return self.categoria(2600) }
	
	method categoria(sueldo) {
		var nuevaCategoria = object {
			var sueldoBase
			
			method getSueldoBase() {
				return sueldoBase
			}
			
			method setSueldoBase(sueldoNuevo) {
				sueldoBase = sueldoNuevo
			}
		}
		
		nuevaCategoria.setSueldoBase(sueldo)
		return nuevaCategoria
	}
	
}