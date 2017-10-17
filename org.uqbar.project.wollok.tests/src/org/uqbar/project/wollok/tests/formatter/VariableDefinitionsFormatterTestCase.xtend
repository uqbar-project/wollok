package org.uqbar.project.wollok.tests.formatter

import org.junit.Ignore
import org.junit.Test

class VariableDefinitionsFormatterTestCase extends AbstractWollokFormatterTestCase {
	
	@Test
	
	def void testSeveralVariableDefinitionsToConstantsInMethods() throws Exception {
		assertFormatting(
		'''
		class Foo {
			var x var y var z		
			method addition() { var   a    =    x x   =     1         y   = 2 z=x+y	}
		}''', 
		'''
		class Foo {
			var x
			var y
			var z
			method addition() {
				var a = x
				x = 1
				y = 2
				z = x + y
			}
		}
		''')
	}

	@Test
	
	def void testSeveralVariableDefinitionsToConstantsInMethods2() throws Exception {
		assertFormatting(
		'''
		class Foo {
			var x var y =     5 var z		
			method addition() { 
				
				
				var a = x 
				
				
				x = 1 
				
				
				y = 2             z = x + y	}
				
				
		}''', 
		'''
		class Foo {
			var x
			var y = 5
			var z
			method addition() {
				var a = x
				x = 1
				y = 2
				z = x + y
			}
		}
		''')
	}

	@Test
	
	def void testSeveralVariableDefinitionsToConstantsInMethods3() throws Exception {
		assertFormatting(
		'''
		class Foo {
						var x var y var z		
						method      addition   ()           { 
										var a = x 
				x = 1 
				y = 2             
										z = x + y	}
				
				
		}''', 
		'''
		class Foo {
			var x
			var y
			var z
			method addition() {
				var a = x
				x = 1
				y = 2
				z = x + y
			}
		}
		''')
	}


	@Test
	
	def void testSeveralVariableDefinitionsToConstantsInMethods4() throws Exception {
		assertFormatting(
		'''
		class Foo {
			var x		
			method addition() { x = 1 var a = 2 a = x a   ++        a  .  inverted() }
		}''', 
		'''
		class Foo {
			var x
			method addition() {
				x = 1
				var a = 2
				a = x
				a++
				a.inverted()
			}
		}
		''')
	}
	
}