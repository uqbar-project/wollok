
object biciVieja {
	var distanciaMaxima = 20
	var distanciaARecorrer = 0

	method capacidad() {
		if (distanciaARecorrer > distanciaMaxima) {
			return 15
		} else {
			return 24
		}
	}

	method puedeLlevar(pedido, distanciaDeViaje) {
		distanciaARecorrer = distanciaDeViaje return pedido <= self.capacidad()
	}
}

object biciNueva {
	method capacidad() {
		return 36
	}

	method puedeLlevar(pedido, distancia) {
		return pedido <= self.capacidad()
	}
}

object motoGrande {
	const distanciaMaxima = 100
	var distanciaRecorrida = 0

	method capacidad() { return 60 }

	method llevarPedido(pedido, distancia) {
		if (self.puedeLlevar(pedido, distancia)) {
			distanciaRecorrida += distancia
		}
	}

	method puedeLlevar(pedido, distancia) {
		return pedido <= self.capacidad() and ( distanciaRecorrida + distancia ) < distanciaMaxima
	}
}

object motoChica {
	const distanciaMaxima = 70
	var distanciaRecorrida = 0

	method capacidad() {
		return 50
	}

	method llevarPedido(pedido, distancia) {
		if (self.puedeLlevar(pedido, distancia)) {
			distanciaRecorrida += distancia
		}
	}

	method puedeLlevar(pedido, distancia) {
		return pedido <= self.capacidad() and ( distanciaRecorrida + distancia ) <
		distanciaMaxima
	}
}

object jose {
	var capacidad = 20
	var cantidadDeViajes = 0
	const distanciaMaxima = 15

	method capacidad() {
		return capacidad - ( 2 * cantidadDeViajes )
	}

	method llevarPedido(pedido, distancia) {
		if (self.puedeLlevar(pedido, distancia)) {
			cantidadDeViajes -= 1
		}
	}

	method puedeLlevar(pedido, distancia) {
		return cantidadDeViajes > 0 and pedido <= self.capacidad() and distancia <
		distanciaMaxima
	}
}

object delivery {
	const transportes = [ biciVieja, biciNueva, motoGrande, motoChica, jose ]

	method cantidadTotalQueSePuedeTransportar() {
		return transportes.sum{ t => t.capacidad() }
	}

	method transportesQuePuedenLlevar(pedido, distancia) {
		return transportes.filter{ t => t.puedeLlevar(pedido, distancia) }
	}

	method esPosibleHacerPedido(pedido, distancia) {
		return transportes.exists{ t => t.puedeLlevar(pedido, distancia) } ;
	}

	method transporteQuePuedeLlevar(pedido, distancia) {
		return transportes.detect{ t => t.puedeLlevar(pedido, distancia) }
	}

	method desperdicio(transporte, pedido, distancia) {
		if (transporte.puedeLlevar(pedido, distancia)) {
			return transporte.capacidad() - pedido
		} else {
			return 0
		}
	}

	method sobrante(transporte, pedido) {
		if (pedido >= transporte.capacidad()) {
			return pedido - transporte.capacidad()
		} else {
			return 0
		}
	}

	method mejorTransporteParaLlevar(pedido, distancia) {
		var desperdicio = 1000
		var mejorTransporte = null
		self.transportesQuePuedenLlevar(pedido, distancia).forEach { t => if
		(self.desperdicio(t, pedido, distancia) < desperdicio) {
			mejorTransporte = t
		} } return mejorTransporte
	}

	method transportesQueNecesitoParaLlevar(pedido, distancia) {
		var pendiente = pedido var transportesNecesarios = [ ] 
		transportes.forEach { t => 
			if (pedido > 0) {
				if (t.puedeLlevar(pedido - t.capacidad(), distancia)) {
					transportesNecesarios.add(t) pendiente -= t.capacidad()
				}
			}
		}
		return transportesNecesarios
	}

	method cantidadDesperdiciadaPorLlevar(pedido, distancia) {
		var transportesQueSalen = self.transportesQueNecesitoParaLlevar(pedido, distancia) 
		return transportesQueSalen.sum{ t => t.capacidad() } - pedido
	}

	method pedidosTotalesVidaUtil() {}

	method transporteOptimo(pedido, distancia) {
		var desperdicio = 1000
		var menorSobrante = 1000
		var mejorTransporte = null
		transportes.forEach { t =>
			if (self.desperdicio(t, pedido, distancia) >= 0 &&  self.desperdicio(t, pedido, distancia) < desperdicio) {
				desperdicio = self.desperdicio(t, pedido, distancia) mejorTransporte = t
			} else if (self.sobrante(t, pedido) >= 0 && self.sobrante(t, pedido) < menorSobrante) {
				menorSobrante = self.sobrante(t, pedido) mejorTransporte = t
			} 
			console.println(mejorTransporte)
		} 
		return mejorTransporte
	}

	method transportesOptimos(pedido, mejoresTransportes, todosLosTransportes) {
		var pendiente = pedido var transporte = null transporte =
		todosLosTransportes.transporteOptimo(pedido)
		mejoresTransportes.add(transporte) todosLosTransportes.remove(transporte)
		pendiente -= pedido - transporte.capacidad() 
		if (pedido >= 0) {
			return self.transportesOptimos(pedido, mejoresTransportes, todosLosTransportes)
		}
		else {
			return mejoresTransportes
		}
	}

	method transportesOptimosPara(pedido) {
		var todosLosTransportes = transportes var mejoresTransportes = [ ] return
		self.transportesOptimos(pedido, mejoresTransportes, todosLosTransportes)
	}
}
