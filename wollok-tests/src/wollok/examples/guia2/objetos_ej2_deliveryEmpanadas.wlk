
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
		distanciaARecorrer = distanciaDeViaje return pedido <= this.capacidad()
	}
}

object biciNueva {
	method capacidad() {
		return 36
	}

	method puedeLlevar(pedido, distancia) {
		return pedido <= this.capacidad()
	}
}

object motoGrande {
	val distanciaMaxima = 100
	var distanciaRecorrida = 0

	method capacidad() { return 60 }

	method llevarPedido(pedido, distancia) {
		if (this.puedeLlevar(pedido, distancia)) {
			distanciaRecorrida += distancia
		}
	}

	method puedeLlevar(pedido, distancia) {
		return pedido <= this.capacidad() and ( distanciaRecorrida + distancia ) < distanciaMaxima
	}
}

object motoChica {
	val distanciaMaxima = 70
	var distanciaRecorrida = 0

	method capacidad() {
		return 50
	}

	method llevarPedido(pedido, distancia) {
		if (this.puedeLlevar(pedido, distancia)) {
			distanciaRecorrida += distancia
		}
	}

	method puedeLlevar(pedido, distancia) {
		return pedido <= this.capacidad() and ( distanciaRecorrida + distancia ) <
		distanciaMaxima
	}
}

object jose {
	var capacidad = 20
	var cantidadDeViajes = 0
	val distanciaMaxima = 15

	method capacidad() {
		return capacidad - ( 2 * cantidadDeViajes )
	}

	method llevarPedido(pedido, distancia) {
		if (this.puedeLlevar(pedido, distancia)) {
			cantidadDeViajes -= 1
		}
	}

	method puedeLlevar(pedido, distancia) {
		return cantidadDeViajes > 0 and pedido <= this.capacidad() and distancia <
		distanciaMaxima
	}
}

object delivery {
	val transportes = #[ biciVieja, biciNueva, motoGrande, motoChica, jose ]

	method cantidadTotalQueSePuedeTransportar() {
		return transportes.sum[ t | t.capacidad() ]
	}

	method transportesQuePuedenLlevar(pedido, distancia) {
		return transportes.filter[ t | t.puedeLlevar(pedido, distancia) ]
	}

	method esPosibleHacerPedido(pedido, distancia) {
		return transportes.exists[ t | t.puedeLlevar(pedido, distancia) ] ;
	}

	method transporteQuePuedeLlevar(pedido, distancia) {
		return transportes.detect[ t | t.puedeLlevar(pedido, distancia) ]
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
		this.transportesQuePuedenLlevar(pedido, distancia).forEach[ t | if
		(this.desperdicio(t, pedido, distancia) < desperdicio) {
			mejorTransporte = t
		} ] return mejorTransporte
	}

	method transportesQueNecesitoParaLlevar(pedido, distancia) {
		var pendiente = pedido var transportesNecesarios = #[ ] 
		transportes.forEach[t | 
			if (pedido > 0) {
				if (t.puedeLlevar(pedido - t.capacidad(), distancia)) {
					transportesNecesarios.add(t) pendiente -= t.capacidad()
				}
			}
		]
		return transportesNecesarios
	}

	method cantidadDesperdiciadaPorLlevar(pedido, distancia) {
		var transportesQueSalen = this.transportesQueNecesitoParaLlevar(pedido, distancia) 
		return transportesQueSalen.sum[ t | t.capacidad() ] - pedido
	}

	method pedidosTotalesVidaUtil() {}

	method transporteOptimo(pedido, distancia) {
		var desperdicio = 1000
		var menorSobrante = 1000
		var mejorTransporte = null
		transportes.forEach[ t | 
			if (this.desperdicio(t, pedido, distancia) >= 0 &&  this.desperdicio(t, pedido, distancia) < desperdicio) {
				desperdicio = this.desperdicio(t, pedido, distancia) mejorTransporte = t
			} else if (this.sobrante(t, pedido) >= 0 && this.sobrante(t, pedido) < menorSobrante) {
				menorSobrante = this.sobrante(t, pedido) mejorTransporte = t
			} 
			console.println(mejorTransporte)
		] 
		return mejorTransporte
	}

	method transportesOptimos(pedido, mejoresTransportes, todosLosTransportes) {
		var pendiente = pedido var transporte = null transporte =
		todosLosTransportes.transporteOptimo(pedido)
		mejoresTransportes.add(transporte) todosLosTransportes.remove(transporte)
		pendiente -= pedido - transporte.capacidad() 
		if (pedido >= 0) {
			return this.transportesOptimos(pedido, mejoresTransportes, todosLosTransportes)
		}
		else {
			return mejoresTransportes
		}
	}

	method transportesOptimosPara(pedido) {
		var todosLosTransportes = transportes var mejoresTransportes = #[ ] return
		this.transportesOptimos(pedido, mejoresTransportes, todosLosTransportes)
	}
}
