class Deposito {
	var camiones = #[]
	
	method cargaEnViaje() {
		return camiones.sum[camion | camion.capacidadDisponible()]
	}
	
	method camionesQueCargan(unContenido) {
		return camiones.filter[camion | camion.estaCargando(unContenido)]
	}
	
	method camionConMayorCantidadDeCosos() {
		return camiones.max[camion | camion.getCosos().size()]
	}		
}

class Camion {
	var cosos = #[]
	var cargaMaxima
	var estado = disponible
	
	new(cargaMaximaPosible) {
		cargaMaxima = cargaMaximaPosible
	}

	method getCosos() {
		return cosos
	}

	method cargaActual() {
		return this.getCosos().sum[bulto | bulto.peso()]
	}

	method puedeCargar(unCoso) {
		return this.tieneLugarPara(unCoso) && estado.sePuedeCargar()
	} 	
	
	method tieneLugarPara(unCoso) {
		return this.cargaActual() + unCoso.peso() <= cargaMaxima
	}
	
	method tieneLugar() {
		return this.cargaActual() < cargaMaxima
	}
	
	method cargar(unCoso) {
		if (this.puedeCargar(unCoso)) {
			this.getCosos().add(unCoso)
		}
	}
	
	method cambiarEstado(nuevoEstado) {
		estado = nuevoEstado
	}
	
	method estaListoParaSalir() {
		return estado.estaListoParaSalir(this)
	}
	
	method capacidadDisponible() {
		return estado.capacidadDisponible(this)
	}
	
	method getCargaMaxima() {
		return cargaMaxima
	}
	
	method estaCargando(unContenido) {
		return this.tieneLugar() && this.getCosos().exists[coso | coso.getContenido() == unContenido]
	}
	
	method cosoMasLiviano() {
		return this.getCosos().min[coso | coso.peso()]
	}
	
	method elementosEnComunCon(otroCamion) {
		return this.getCosos().filter[coso | otroCamion.getCosos().contains(coso)] 
	}
}

class CamionReutilizable extends Camion {
	var destinos = #[]
	
	override method getCosos() {
		return destinos.map[destino | destino.getCosos()].flatten() 
	}
	
	method descargarCamionEn(unLugar) {
		destino.remove(destinos.detect[destino | destino.getLugar() == unLugar])
	}
	
	method cargarUnCosoEnDestino(unCoso, unLugar) {
		if(this.puedeCargar(unCoso)) {
			var destino = destinos.detect[destino | destino.getLugar() == unLugar]
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
	var deposito
	var cosos = #[]
	
	new(unLugar) {
		lugar = unLugar
	}
	
	method getLugar() {
		return lugar
	}
	
	method getCosos() {
		return cosos
	}	
}

class Bulto {
	var cantidadCajas
	var pesoCaja
	var pesoEstructura
	var contenido
	
	new(unaCantidadCajas, pesoCadaCaja, pesoEstructuraMadera, contenidoCaja) {
		cantidadCajas - unaCantidadCajas
		pesoCaja = pesoCadaCaja
		pesoEstructura = pesoEstructuraMadera
		contenido = contenidoCaja
	}
	
	method peso() {
		return (pesoCaja * cantidadCajas) + pesoEstructura
	}
	
	method getContenido() {
		return contenido
	}
}

class Caja {
	var pesoCaja
	var contenido
	
	new(pesoCadaCaja, contenidoCaja) {
		pesoCaja = pesoCadaCaja
		contenido = contenidoCaja
	}
	
	method peso() {
		return pesoCaja
	}
	
	method getContenido() {
		return contenido
	}
}

class Bidon {
	var capacidad
	var densidad
	var contenido
	
	new(capacidadLitros, densidadLiquido) {
		capacidad = capacidadLitros
		densidad = densidadLiquido
	}
	
	method peso() {
		return capacidad * densidad
	}
	
	method getContenido() {
		return contenido
	}
	
}

object disponible {
	method sePuedeCargar() {
		return true
	}
	
	method estaListoParaSalir(camion) {
		return camion.cargaActual() >= camion.getCargaMaxima() * 0.75
	}
	
	method capacidadDisponible(camion) {
		if(camion.tieneLugar()) {
			return camion.getCargaMaxima() - camion.getCargaActual()
		}
	}
}

object enReparacion {
	method sePuedeCargar() {
		return false	
	}
	
	method capacidadDisponible(camion) {
		return 0 
	}
	
	method estaListoParaSalir(camion) {
		return false
	}
}

object deViaje {
	method sePuedeCargar() {
		return false
	}
	
	method capacidadDisponible(camion) {
		return 0 
	}
	
	method estaListoParaSalir(camion) {
		return false
	}	
}

object main {
	var caja1 = new Caja(5, "mochilas")
	var caja2 = new Caja(10, "pares de zapatos")
	var camion1 = new Camion(500)
	
	method cargarCamion(camion) {
		camion.cargar(caja1)
		camion.cargar(caja2)
	}
	
	method cargaActualCamion(camion) {
		return camion.cargaActual()
	}
	
	method getCamion1() {
		return camion1
	}
	
	method getCaja1(){
 		return caja1
 	}
 }