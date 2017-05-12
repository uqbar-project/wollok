package org.uqbar.project.wollok.tests.libraries

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test
import org.eclipse.xtext.testing.InjectWith
import java.io.File

@InjectWith(LoadLibraryWollokTestInjector)
class LoadLibraryTest extends AbstractWollokInterpreterTestCase {
	

	@Test
	def void testFindJar() {
		assertNotNull(new File("wollokLib/pepeLib.jar").toURI().toURL())
	}


	@Test
	def void testPepeObjectExist() {
		'''
		import pepefile.pepe
		test "pepe saluda" {
			assert.equals('hola', pepe.hola())
		}
		'''.interpretPropagatingErrors
	
	}

	
	
}