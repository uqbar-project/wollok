class Deposito {
	val formaciones = #[]
	
	method agregarFormacion(unTren) { formaciones.add(unTren) }
	method vagonesMasPesados() { formaciones.map([t| t.vagonMasPesado()]).flatten() }
}

class Tren {
	val vagones = #[]
	val locomotoras = #[]
	
	method agregarVagon(v) { vagones.add(v) }
	method getCantidadPasajeros() = vagones.sum[v| v.getCantidadPasajeros()] 
	method getCantidadVagonesLivianos() = vagones.count[v| v.esLiviano()]
	method getVelocidadMaxima() = locomotoras.min[l| l.getVelocidadMaxima() ].getVelocidadMaxima()
	method agregarLocomotora(loco) { locomotoras.add(loco)	}
	method esEficiente() = locomotoras.forAll[l| l.esEficiente()]
	method puedeMoverse() = this.arrastreUtilTotalLocomotoras() >= this.pesoMaximoTotalDeVagones()
	method arrastreUtilTotalLocomotoras() = locomotoras.sum[l| l.arrastreUtil()]
	method pesoMaximoTotalDeVagones() = vagones.sum[v| v.getPesoMaximo()]
	method getKilosEmpujeFaltantes() =
		if (this.puedeMoverse())
			0
		else
			this.pesoMaximoTotalDeVagones() - this.arrastreUtilTotalLocomotoras()
	method vagonMasPesado() = vagones.max([v| v.getPesoMaximo() ])
}

class Locomotora {
	var peso
	var pesoMaximoArrastre
	var velocidadMaxima
	constructor(pes, pesoMaxA, veloMax) { peso = pes ; pesoMaximoArrastre = pesoMaxA ; velocidadMaxima = veloMax }
	method getVelocidadMaxima() = velocidadMaxima 
	
	method esEficiente() = pesoMaximoArrastre >= 5 * peso
	method arrastreUtil() = pesoMaximoArrastre - peso
}

class Vagon {
	method esLiviano() = this.getPesoMaximo() < 2500
	method getCantidadPasajeros() 
	method getPesoMaximo()
}

class VagonPasajeros inherits Vagon {
	var ancho
	var largo
	constructor(a, la) { ancho = a ; largo = la }
	
	override method getCantidadPasajeros() {
		return largo * if (ancho < 2.5) 8 else 10
	}
	override method getPesoMaximo() {
		return this.getCantidadPasajeros() * 80
	}
}

class VagonCarga inherits Vagon {
	var cargaMaxima
	constructor(cargaM) {
		cargaMaxima = cargaM
	}
	override method getCantidadPasajeros() = 0
	override method getPesoMaximo() = cargaMaxima + 160
}

