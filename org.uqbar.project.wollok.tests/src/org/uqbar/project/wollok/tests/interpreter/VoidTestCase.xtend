package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * 
 * @author dodain
 */
class VoidTestCase extends AbstractWollokInterpreterTestCase {
	
	def String wkoWithVoidMethods() {
		'''
		class Ejemplo {
			var fecha
		
			constructor(_fecha) {
				fecha = _fecha
			}
		
			method hoy() {
				fecha.day()
			}
		
		}

		object comparar {
		
			var date = new Date()
			var fecha = new Ejemplo(date)
		
			method diaMayorA(otroDia) {
				return otroDia > fecha.hoy()
			}
		
		}
		'''	
	}
	
	@Test
	def void voidInAssert() {
		'''
		«wkoWithVoidMethods»

		program a {
			var dia = new Date()
			var fecha = new Ejemplo(dia)
			assert.throwsExceptionWithMessage(
				"Message call \"fecha.hoy()\" produces no value (missing return in method?)", 
				{ assert.equals("27", fecha.hoy()) }
			)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void voidInBinaryOperation() {
		'''
		«wkoWithVoidMethods»

		program a {
			var dia = new Date()
			var fecha = new Ejemplo(dia)
			assert.throwsExceptionWithMessage(
				"Message call \"fecha.hoy()\" produces no value (missing return in method?)", 
				{ assert.that(comparar.diaMayorA(15)) }
			)
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void voidInUnaryOperation() {
		'''
		«wkoWithVoidMethods»

		program a {
			var dia = new Date()
			var fecha = new Ejemplo(dia)
			assert.throwsExceptionWithMessage(
				"Message call \"fecha.hoy()\" produces no value (missing return in method?)", 
				{ assert.that(fecha.hoy().abs()) }
			)
		}
		'''.interpretPropagatingErrors
	}
	
}