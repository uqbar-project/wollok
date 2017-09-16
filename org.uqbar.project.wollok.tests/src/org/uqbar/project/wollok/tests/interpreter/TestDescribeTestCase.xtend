package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

/**
 * 
 * New tests using describe abstraction that groups tests 
 * 
 * @author dodain
 */
class TestDescribeTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testFixture() {
		'''
		class Golondrina { 
			var energia = 100
			method energia() = energia
			method volar(metros) { energia -= metros * 4 }
			method comer(comida) { energia += comida.energia() }
		}
		
		object alpiste { 
			method energia() = 5
		}
		
		describe "pepita cuando está gorda" {
			const pepita = new Golondrina()
		
			fixture {
				(1..100).forEach({ n => pepita.comer(alpiste) })
			}
			
			test "pepita quedo gorda, vuela un poco para bajar de peso" {
				assert.equals(600, pepita.energia())
				pepita.volar(25)
				assert.equals(500, pepita.energia())
			}
			
			test "pepita sigue gorda en el proximo test" {
				assert.equals(600, pepita.energia())
			}
		}
		'''.interpretPropagatingErrors
	}
	
	// Test describe tests
	@Test
	def void describeCanGroupASetOfIsolatedTestsWithoutState() {
		'''
		describe "pruebas generales" {
			test "Max between 5 and 8" {
				assert.equals(8, 5.max(8))
			}
			test "Min between 5 and 8" {
				assert.equals(5, 5.min(8))
			}
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void describeCanGroupASetOfIsolatedTestsWithLocalVariables() {
		'''
		describe "pruebas generales" {
			test "Max between 5 and 8" {
				const a = 8
				const b = 5
				const result = 5.max(8)
				assert.equals(8, result)
			}
			test "Min between 5 and 8" {
				const a = 8
				const b = 5
				const result = 5.min(8)
				assert.equals(5, result)
			}
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void describeCanGroupASetOfIsolatedTestsWithInstanceVariables() {
		'''
		describe "pruebas generales" {
			const a = 8
			const b = 5
			
			test "Max between 5 and 8" {
				const result = 5.max(8)
				assert.equals(8, result)
			}
			test "Min between 5 and 8" {
				assert.equals(5, 5.min(8))
			}
		}
		'''.interpretPropagatingErrors
	}
	
	@Test(expected=AssertionError)
	def void testShouldNotUseSameVariableDefinedInDescribe() {
		'''
		describe "pruebas generales" {
			const a = 8
			const b = 5
			
			test "Max between 5 and 8" {
				const a = 3
				const result = 5.max(8)
				assert.equals(8, result)
			}
			test "Min between 5 and 8" {
				const result = 5.min(8)
				assert.equals(5, result)
			}
		}
		'''.interpretPropagatingErrors
	}
	@Test
	def void testWithMethodInvocation() {
		'''
		describe "pruebas generales" {
			const one = 1
			
			method uno() = 1
			
			test "Uno es one" {
				assert.equals(one, self.uno())
			}
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testVariableOfDescribeDoesntHaveSideEffectsBetweenTests() {
		'''
		describe "pruebas generales" {
			var one = 1
			
			method sumarOne() {
				one = one + 1
			}
			
			method uno() = 1
			
			test "Dos es one + 1" {
				self.sumarOne()
				assert.equals(one, self.uno() + 1)
			}
			
			test "Uno es one" {
				assert.equals(one, self.uno())
			}
		}
		'''.interpretPropagatingErrors
	}

	@Test(expected=WollokProgramExceptionWrapper)
	def void testFixtureErrorBreaksTestsInDescribe() {
		'''
		describe "conjunto de tests re locos" {
		
			var uno
			
			fixture {
				uno = 1 / 0	
			}
			
			method uno() = uno
			method dos() = self.uno() + 1
			
			test "uno es uno" {
				assert.equals(1, uno)
			}
		
			test "dos es dos" {
				var dos = self.dos()
				self.uno()
				assert.equals(2, dos)
			}
			
		}
		'''.interpretPropagatingErrors
	}

	@Test(expected=AssertionError)
	def void testConstReferencesCannotBeDefinedInAFixture() {
		'''
		describe "conjunto de tests re locos" {
		
			fixture {
				const uno = 1
			}
			
			test "uno es uno" {
				assert.equals(1, uno)
			}
			
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testConstReferencesCannotBeAssignedInAFixture() {
		'''
		describe "conjunto de tests que prueban que se puede inicializar adicionalmente en el fixture" {
		
			const uno = 1
			
			fixture {
				uno = 1
			}
			
			test "uno es uno" {
				assert.equals(1, uno)
			}
			
		}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testConstReferencesCanBeInitiallyAssignedInAFixture() {
		'''
		describe "conjunto de tests re locos" {
		
			const uno
			
			fixture {
				uno = 1
			}
			
			test "uno es uno" {
				assert.equals(1, uno)
			}
			
		}
		'''.interpretPropagatingErrors
	}
			
}