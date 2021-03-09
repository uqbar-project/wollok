package org.uqbar.project.wollok.tests.formatter

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
class ConstructorCallsFormatterTestCase extends AbstractWollokFormatterTestCase {
	
	@Test
	def void constructorCallFormatting() throws Exception {
		assertFormatting('''
		class A { var a
		var b = 2 var c var d 
		}
		class B {
			
		method buildA() {
		new A(                     a
		
		
		 = 
		 
		 200			
		,
		b                = "Hello"
		
		,
		
		c =               new        Date()    
		
		, d=#{1   , 8} )	
		}
		''', 
		'''
		class A {
		
			var a
			var b = 2
			var c
			var d
		
		}
		
		class B {
		
			method buildA() {
				new A(a = 200, b = "Hello", c = new Date(), d = #{ 1, 8 })
			}
		
		}
		
		''')
	}
}