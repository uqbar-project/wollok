class Deposito {
	var camiones = []
	
	method cargaEnViaje() = camiones.sum{camion => camion.capacidadDisponible()}
	
	method camionesQueCargan(unContenido) = camiones.filter{camion => camion.estaCargando(unContenido)}
	
	method camionConMayorCantidadDeCosos() = camiones.max{camion => camion.getCosos().size()}
}

class Camion {
	var cosos = []
	var cargaMaxima
	var estado = disponible
	
	constructor(cargaMaximaPosible) { cargaMaxima = cargaMaximaPosible }

	method getCosos() = cosos

	method cargaActual() =self.getCosos().sum{bulto => bulto.peso()}

	method puedeCargar(unCoso) = self.tieneLugarPara(unCoso) && estado.sePuedeCargar()
	
	method tieneLugarPara(unCoso) = self.cargaActual() + unCoso.peso() <= cargaMaxima
	
	method tieneLugar() = self.cargaActual() < cargaMaxima
	
	method cargar(unCoso) { if (self.puedeCargar(unCoso)) self.getCosos().add(unCoso) }
	
	method cambiarEstado(nuevoEstado) { estado = nuevoEstado }
	
	method estaListoParaSalir() = estado.estaListoParaSalir(self)
	
	method capacidadDisponible() = estado.capacidadDisponible(self)
	
	method getCargaMaxima() = cargaMaxima
	
	method estaCargando(unContenido) = self.tieneLugar() && self.getCosos().exists{coso => coso.getContenido() == unContenido}
	
	method cosoMasLiviano() = self.getCosos().min{coso => coso.peso()}
	
	method elementosEnComunCon(otroCamion) = self.getCosos().filter{coso => otroCamion.getCosos().contains(coso)} 
}

class CamionReutilizable inherits Camion {
	var destinos = []
	
	constructor(cargaMaximaPosible) = super(cargaMaximaPosible)
	
	override method getCosos() = destinos.map{destino => destino.getCosos()}.flatten() 
	
	method descargarCamionEn(unLugar) { destino.remove(destinos.detect{destino => destino.getLugar() == unLugar}) }
	
	method cargarUnCosoEnDestino(unCoso, unLugar) {
		if(self.puedeCargar(unCoso)) {
			var destino = destinos.detect{destino => destino.getLugar() == unLugar}
			if (destino == null) {
				var nuevoDestino = new Destino(unLugar)
				nuevoDestino.getCosos().add(unCoso)
				destino.add(nuevoDestino)
			} else {
				destino.getCosos().add(unCoso)
			}
		}
	}
}

class Destino {
	var lugar
	var cosos = []
	
	constructor(unLugar) { lugar = unLugar }
	method getLugar() = lugar 
	method getCosos() = cosos
}

class Bulto {
	var cantidadCajas
	var pesoCaja
	var pesoEstructura
	var contenido
	
	constructor(unaCantidadCajas, pesoCadaCaja, pesoEstructuraMadera, contenidoCaja) {
		cantidadCajas - unaCantidadCajas
		pesoCaja = pesoCadaCaja
		pesoEstructura = pesoEstructuraMadera
		contenido = contenidoCaja
	}
	
	method peso() = (pesoCaja * cantidadCajas) + pesoEstructura
	
	method getContenido() = contenido
}

class Caja {
	var pesoCaja
	var contenido
	
	constructor(pesoCadaCaja, contenidoCaja) {
		pesoCaja = pesoCadaCaja
		contenido = contenidoCaja
	}
	
	method peso() = pesoCaja
	
	method getContenido() = contenido
}

class Bidon {
	var capacidad
	var densidad
	var contenido
	
	constructor(capacidadLitros, densidadLiquido) {
		capacidad = capacidadLitros
		densidad = densidadLiquido
	}
	
	method peso() = capacidad * densidad
	method getContenido() = contenido
	
}

object disponible {
	method sePuedeCargar() = true
	
	method estaListoParaSalir(camion) = camion.cargaActual() >= camion.getCargaMaxima() * 0.75
	
	method capacidadDisponible(camion) {
		if (camion.tieneLugar()) {
			return camion.getCargaMaxima() - camion.getCargaActual()
		}
		else return 0
	}
}

object enReparacion {
	method sePuedeCargar() = false	
	method capacidadDisponible(camion) = 0 
	method estaListoParaSalir(camion) = false
}

object deViaje {
	method sePuedeCargar() = false
	method capacidadDisponible(camion) = 0 
	method estaListoParaSalir(camion) = false
}

object main {
	var caja1 = new Caja(5, "mochilas")
	var caja2 = new Caja(10, "pares de zapatos")
	var camion1 = new Camion(500)
	
	method cargarCamion(camion) {
		camion.cargar(caja1)
		camion.cargar(caja2)
	}
	
	method cargaActualCamion(camion) = camion.cargaActual()
	method getCamion1() = camion1
	method getCaja1() = caja1

 }