import trenes.*

// 1)
program trenes {

val tren = new Tren()
tren.agregarVagon(new VagonPasajeros(2, 10))
this.assertEquals(80, tren.getCantidadPasajeros())

tren.agregarVagon(new VagonPasajeros(3, 10))
this.assertEquals(180, tren.getCantidadPasajeros())

tren.agregarVagon(new VagonCarga(1000))
this.assertEquals(180, tren.getCantidadPasajeros())


// 2) Cuántos vagones livianos tiene una formación;
this.assertEquals(1, tren.getCantidadVagonesLivianos()) // el de carga


// 3) La velocidad máxima de una formación,
tren.agregarLocomotora(new Locomotora(1020, 8100, 60)) // de 60 kpm
tren.agregarLocomotora(new Locomotora(1400, 10000, 75)) // de 60 kpm

this.assertEquals(60, tren.getVelocidadMaxima())

// 4) Si una formación es eficiente;

this.assert(new Locomotora(10, 50, 0).esEficiente())
this.assert(new Locomotora(10, 51, 0).esEficiente())
this.assertFalse(new Locomotora(10, 49, 0).esEficiente())

this.assert(tren.esEficiente())

// 5) Si una formación puede moverse.

this.assert(tren.puedeMoverse())

// 6) Cuántos kilos de empuje le faltan a una formación para poder moverse,

this.assert(0 == tren.getKilosEmpujeFaltantes())

val trenNoSeMueve = new Tren()
trenNoSeMueve.agregarVagon(new VagonPasajeros(3, 12))
trenNoSeMueve.agregarLocomotora(new Locomotora(1200, 4000, 55))
this.assertFalse(trenNoSeMueve.puedeMoverse())
this.assertEquals(6800, trenNoSeMueve.getKilosEmpujeFaltantes())

// 7) Dado un depósito, obtener el conjunto formado por el vagón más pesado de cada formación;

val deposito = new Deposito()
deposito.agregarFormacion(tren)
deposito.agregarFormacion(trenNoSeMueve)

this.assert(2 == deposito.vagonesMasPesados().size())

this.println("FIIIIN")
}