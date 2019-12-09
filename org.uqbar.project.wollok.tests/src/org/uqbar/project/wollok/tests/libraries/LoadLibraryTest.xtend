package org.uqbar.project.wollok.tests.libraries

import org.eclipse.xtext.testing.InjectWith
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Disabled

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

	@Disabled
	@Test
	def void testInnerLocationObjectExist() {
		'''
		import org.uqbar.josepackage.jose
		test "pepito saluda" {
			assert.equals('hola Don Pepito', jose.hola())
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void nativeObjectInLibrary() {
		'''
		import flagpackage.Flag
		test "flag exist" {
			var f = new Flag()
			f.on()
			assert.that(f.value())
			f.off()
			assert.notThat(f.value())
		}
		'''.interpretPropagatingErrors
	}	

}