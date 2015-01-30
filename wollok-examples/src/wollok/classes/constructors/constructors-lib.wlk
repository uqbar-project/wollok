package constructorsLib {
	
class Direccion {
	var calle = ""
	var numero = 0
	
	new(c, n) {
		calle = c
		numero = n
	}
	
	method getCalle() { calle }
	method getNumero() { numero }
}
	
	
}