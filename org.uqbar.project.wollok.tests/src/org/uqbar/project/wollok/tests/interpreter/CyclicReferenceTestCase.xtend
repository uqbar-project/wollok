package org.uqbar.project.wollok.tests.interpreter

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test
import static org.uqbar.project.wollok.WollokConstants.*

/**
 * Moved from Wollok Language until we discuss lazy feature
 *  
 * @author dodain
 */
class CyclicReferenceTestCase extends AbstractWollokInterpreterTestCase {
	
	def String classDefinitions() {
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
		'''
	}

	@Test
	def void testCyclicReferencesClass() {
		'''
		«classDefinitions»
		
		const unEquipo = new Equipo(entrenador = unEntrenador)	
		const unEntrenador = new Entrenador(equipo = unEquipo)	
		
		test "cyclic references for instance named params" {	
		  assert.that(unEntrenador.estaContento())	
		  assert.that(unEquipo.bienEntrenado())	
		}	
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCyclicReferencesWKOInheritingFromClass() {
		'''
		«classDefinitions»
		
		object elEquipo inherits Equipo(entrenador = elEntrenador) { }
		object elEntrenador inherits Entrenador(equipo = elEquipo) { }
		
		test "cyclic references for named objects with inherits named params" {
		  assert.that(elEntrenador.estaContento())
		  assert.that(elEquipo.bienEntrenado())
		}
		'''.interpretPropagatingErrors
	}

}