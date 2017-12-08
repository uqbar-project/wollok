package org.uqbar.project.wollok.tests.formatter

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
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

	@Test
	def void propertyDefinitionInClass() throws Exception {
		assertFormatting(
		'''
		class Foo {
			var              property 
			
			
			 x
			 
			 const 
			 property
			 
			 
			 y
			    =    
			      1		
		}''', 
		'''
		class Foo {
		
			var property x
			const property y = 1
		
		}
		
		''')
	}

	@Test
	def void propertyDefinitionInWko() throws Exception {
		assertFormatting(
		'''
		object romualdo {
			var      property 
			
			
			 x
			 
			 const
			 
			 property
			 
			 
			  y
			    =    
			      1		
		}''', 
		'''
		object romualdo {
		
			var property x
			const property y = 1
		
		}
		
		''')
	}
	
	@Test
	def void propertyDefinitionInMixin() throws Exception {
		assertFormatting(
		'''
		mixin Jugable {
			         var   property 
			
			
			 x
			 
			 const         
			 property
			 
			 
			  y
			    =    
			      1		
		}''', 
		'''
		mixin Jugable {
		
			var property x
			const property y = 1
		
		}
		
		''')
	}
	
	@Test
	def void propertyDefinitionInDescribe() throws Exception {
		assertFormatting(
		'''
		describe
		
		 "group of tests"  
		 {
			var					property         
			
			
			 x
			 
			 const  			property
			 
			 
			 y
			    =    
			      1		
			      
			      test "true is true" { assert.that(true) }
		}''', 
		'''
		describe "group of tests" {
		
			var property x
			const property y = 1
		
			test "true is true" {
				assert.that(true)
			}
		
		}
		
		''')
	}
	
}