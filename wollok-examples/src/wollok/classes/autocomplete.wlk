program autocomplete {

	// *************
	// vars in the same scope
	
	var perro = object {
		method correr(cuanto) {}
		method caminar(cuanto) {}
		method moverLaCola() {}
	}
	
	perro.caminar(23)
	
	val km = 2
	perro.correr(km)
	perro.moverLaCola()
	
	//here CTRL+SPACE
	
	// *************
	// instance variables usage
	
	val loro = object {
		var plumas = object {}
		method moverPlumas() {
	//		plumas.mover()
			//plumas.
		}
		method volar() {
			// here also completes based on the first method
			//plumas. 
		}
	}
	loro
	
	// *************
	// closures
	
	var aBlock = [auto |
		// ufa, no anda acá.
	]
	
	
	var otro = [auto | auto.arrancar() ]

}