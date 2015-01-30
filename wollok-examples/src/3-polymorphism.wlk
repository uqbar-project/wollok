program polymorphism {

// 3ro: objetos como parametro

val pepona = object {
	var energia = 100
	method comer(comida) {
		energia = energia + comida.energia()
	}
	method energia() { energia }
}

val alpiste = object {
	method energia() { 5 } 
}

pepona.comer(alpiste)

// Comento porque si no da un error al correr WollokExamplesTests
// pepona.comer(23) 

this.assert(pepona.energia() == 105)

}