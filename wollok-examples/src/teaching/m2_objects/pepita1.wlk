
program pepita1 {
	var console = this
	
	// Todo muy lindo hasta acá, pero la gracia es poder definir nuestros propios objetos
	var pepita = object {
		var energia = 100
		
		method energia() {
			console.println("hola")
			energia
		}
	}

	this.println(pepita)	
	this.println(pepita.energia())	
}
