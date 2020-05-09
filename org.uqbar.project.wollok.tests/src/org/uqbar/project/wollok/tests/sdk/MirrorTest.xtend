package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

class MirrorTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void instanceVariableFor() {
		'''
		import wollok.mirror.ObjectMirror
		
		class Perro {
			var nombre = "Colita"
			var edad = 7
		}
		
		program p {
			const perro = new Perro()
			
			const mirror = new ObjectMirror(target = perro)
			const instVar = mirror.instanceVariableFor("nombre")
			
			assert.that(instVar != null)
			
			assert.equals("nombre", instVar.name())
			assert.equals("Colita", instVar.value())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void instanceVariables() {
		'''
		import wollok.mirror.ObjectMirror
		
		class Perro {
			var nombre = "Colita"
			var edad = 7
		}
		
		program p {
			const perro = new Perro()
			
			const mirror = new ObjectMirror(target = perro)
			const instVars = mirror.instanceVariables()
			assert.equals(2, instVars.size())
			
			const nombreInstVar = instVars.find{e=> e.name() == "nombre"}
			assert.equals("Colita", nombreInstVar.value())
			
			const edadInstVar = instVars.find{e=> e.name() == "edad"}
			assert.equals(7, edadInstVar.value())
			
«««				assert.equals("#[edad=7, nombre=Colita]",instVars.toString())
		}
		'''.interpretPropagatingErrors
	}
	
}