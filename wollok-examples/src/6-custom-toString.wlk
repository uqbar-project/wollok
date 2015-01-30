program customToString {

val pepe = object {
	method toString() {
		'Pepe'
	}
}

this.println(pepe)
this.assert(pepe.toString() == 'Pepe')

}