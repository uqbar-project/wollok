package org.uqbar.project.wollok.tests.libraries

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test
import org.eclipse.xtext.testing.InjectWith
import java.io.File

//This injector creates lib parameter 
@InjectWith(LoadLibraryWollokTestInjector)
class LoadLibraryTest extends AbstractWollokInterpreterTestCase {
	

	@Test
	def void testRootLocationObjectExist() {
		'''
		import pepitopackage.pepito
		test "pepito saluda" {
			assert.equals('hola Don Jose', pepito.hola())
		}
		'''.interpretPropagatingErrors
	
	}

	@Test
	def void testInnerLocationObjectExist() {
		'''
		import org.uqbar.josepackage.jose
		test "pepito saluda" {
			assert.equals('hola Don Pepito', jose.hola())
		}
		'''.interpretPropagatingErrors
	
	}
	
	
}