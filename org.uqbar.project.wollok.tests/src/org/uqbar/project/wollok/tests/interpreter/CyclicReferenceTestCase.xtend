package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * @author dodain
 */
class CyclicReferenceTestCase extends AbstractWollokInterpreterTestCase {

	@Test
	def void cyclicReferencesOnInstantiation() {
		'''
		class Entrenador{
		  var property equipo
		  
		  method estaContento() = equipo.esBueno()
		}
		
		class Equipo {	
		  var property entrenador
		  
		  method esBueno() = true
		  method bienEntrenado() = entrenador.estaContento()
		}

		const unEquipo = new Equipo(entrenador = unEntrenador)
		const unEntrenador = new Entrenador(equipo = unEquipo)
		
		test "las referencias cíclicas funcionan lazy" {
			assert.that(unEntrenador.estaContento())
			assert.that(unEquipo.bienEntrenado())
		}
		'''.interpretPropagatingErrors
	}
	
}