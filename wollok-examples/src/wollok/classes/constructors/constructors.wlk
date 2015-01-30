import constructorsLib.*

program constructors {
	val direccion = new Direccion("Jose Marti", 155)
	this.assertEquals("Jose Marti", direccion.getCalle())
	this.assertEquals(155, direccion.getNumero())
}