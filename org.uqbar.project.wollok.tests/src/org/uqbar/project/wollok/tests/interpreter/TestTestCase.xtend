package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import wollok.lib.AssertionException
import org.junit.Assert

/**
 * @author tesonep
 * @author jfernades
 */
class TestTestCase extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testWithAssertsOk() {
		'''
			object pepita {
				var energia = 0
				method come(cantidad){
					energia = energia + cantidad * 10
				}
				method energia(){
					return energia
				}
			}

			program p {
				assert.that(pepita.energia() == 0)	
				assert.equals(0, pepita.energia())	
				
				pepita.come(10)
				assert.equals(100, pepita.energia())	
			}
		'''.interpretPropagatingErrors
	}

	@Test
	def void testWithAssertEqualsWithErrors() {
			'''
				object pepita {
					var energia = 0
					method come(cantidad){
						energia = energia + cantidad * 10
					}
					method energia(){
						return energia
					}
				}

				program pepitao {
					try {
						assert.equals(7, pepita.energia())
						assert.fail("should have failed")
					}
					catch e {
						assert.equals("Expected [7] but found [0]", e.getMessage())
					} 	
				}
			'''.interpretPropagatingErrors
	}

	@Test(expected = AssertionError)
	def void testWithAssertsWithErrors() {
		'''
			object pepita {
				var energia = 0
				method come(cantidad){
					energia = energia + cantidad * 10
				}
				method energia(){
					return energia
				}
			}

			program p {
				tester.assert(7 == pepita.energia())	
			}
		'''.interpretPropagatingErrors
	}
	
	@Test(expected = AssertionError)
	def void testWithExpectedExceptionWithErrors() {
		'''
			program p {
				assert.throwsException { 4 }	
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testWithExpectedExceptionWithoutErrors() {
		'''
			program p {
				assert.throwsException { 
					const x = null
					x.foo()
				}	
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testsAreIsolatedInTermsOfStateWKO() {
		'''
			object globalin {
				var a = 10
				method a(nuevo) { a = nuevo }
				method a() = a
			}
			test "Changing a to 20" {
				assert.equals(10, globalin.a())
				globalin.a(20)
				assert.equals(20, globalin.a())
			}
			test "Is back in 10 and change it to 30" {
				// starts with 10 again !
				assert.equals(10, globalin.a())
				globalin.a(30)
				assert.equals(30, globalin.a())
			}
			test "Changing a to 10" {
				// starts with 10 again !
				assert.equals(10, globalin.a())
			}
		'''.interpretPropagatingErrors
	}
	@Test
	def void throwsSpecialKindOfExceptionCatchTheSpecifiedException() {
		'''
			class BusinessException inherits wollok.lang.Exception {
				constructor() {}
			}
			test "Use throwsExceptionLike" {
				assert.throwsExceptionLike(new BusinessException(), { => throw new BusinessException() })
			}
		'''.interpretPropagatingErrors
	}
	@Test
	def void throwsSpecialKindOfExceptionFailsWhenCatchTheSpecifiedExceptionButWithOtherMessage() {
		'''
			class BusinessException inherits wollok.lang.Exception {
				constructor(_message) {message = _message}
			}
			test "Use throwsExceptionLike" {
				try {
					assert.throwsExceptionLike(new BusinessException("chau"), { => throw new BusinessException("hola") })
				}
				catch ex {
					assert.equals(ex.getMessage(), "The Exception expected was a BusinessException[message=chau, cause=null] but got a BusinessException[message=hola, cause=null]")
				}
			}
		'''.interpretPropagatingErrors
	}	
	@Test
	def void throwsSpecialKindOfExceptionDontCatchOtherException() {
		'''
			class BusinessException inherits wollok.lang.Exception {
				constructor() {}
			}
			class OtherBusinessException inherits wollok.lang.Exception {
				constructor() {}
			}			
			program a {
					try {
						assert.throwsExceptionLike(new BusinessException(), { => throw new OtherBusinessException() })
					}
					catch ex {
						assert.equals(ex.getMessage(), "The Exception expected was a BusinessException[message=null, cause=null] but got a OtherBusinessException[message=null, cause=null]")
					}
			}
		'''.interpretPropagatingErrors
	}
	@Test
	def void throwsSpecialKindOfExceptionFailsWhenBlockDontThrownAnException() {
		'''
			class BusinessException inherits wollok.lang.Exception {
					constructor() {}
			}
			program a {
					try {
						assert.throwsExceptionLike(new BusinessException(), { => console.println("Works great!")})
					}
					catch ex {
						assert.equals("Should have thrown an exception", ex.getMessage())
					}
			}
		'''.interpretPropagatingErrors
	}
	@Test
	def void trowsExceptionExpectsADessireMessage (){
		'''
			class BusinessException inherits wollok.lang.Exception {
				constructor(_message) {message = _message}
			}
			test "Use throwsExceptionWithMessage" {
				assert.throwsExceptionWithMessage("hola!", { => throw new BusinessException("hola!") })
			}
		'''.interpretPropagatingErrors		
	}
	@Test
	def void trowsExceptionExpectsADessireMessageButGotOther (){
		'''
			class BusinessException inherits wollok.lang.Exception {
				constructor(_message) {message = _message}
			}
			test "Use throwsExceptionWithMessage" {
				try {
					assert.throwsExceptionWithMessage("hola!", { => throw new BusinessException("Jamaica") })
				}
				catch ex {
					assert.equals("The error message expected was hola! but got Jamaica", ex.getMessage())
				}
			}
		'''.interpretPropagatingErrors		
	}
	@Test
	def void trowsExceptionExpectsADessireExceptionClassWithDifferentMessages (){
		'''
			class BusinessException inherits wollok.lang.Exception {
				constructor(_message) {message = _message}
			}
			test "Use throwsExceptionWithType" {
				assert.throwsExceptionWithType(new BusinessException("lala"), { => throw new BusinessException("hola!") })
			}
		'''.interpretPropagatingErrors		
	}
	@Test
	def void trowsExceptionExpectsADesiredExceptionClassButGotOther (){
		#['exepciones' -> '''
			class BusinessException inherits wollok.lang.Exception {
				constructor(_message) {message = _message}
			}
			class OtherException inherits wollok.lang.Exception {
				constructor(_message) {message = _message}
			}
		''',
		'programa' -> '''
			import exepciones.*
			test "Use throwsExceptionWithType" {
				try {
					assert.throwsExceptionWithType(new BusinessException("hola!"), { => throw new OtherException("hola!") })
				}
				catch ex {
					assert.equals("The exception expected was exepciones.BusinessException but got exepciones.OtherException", ex.getMessage())
				}
			}
		'''
		].interpretPropagatingErrors		
	}
	
	// Test suite tests
	@Test
	def void suiteCanGroupASetOfIsolatedTestsWithoutState() {
		'''
			suite "pruebas generales" {
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
	def void suiteCanGroupASetOfIsolatedTestsWithLocalVariables() {
		'''
			suite "pruebas generales" {
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
	def void suiteCanGroupASetOfIsolatedTestsWithInstanceVariables() {
		'''
			suite "pruebas generales" {
				const a = 8
				const b = 5
				
				test "Max between 5 and 8" {
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
	
	@Test(expected=AssertionError)
	def void testShouldNotUseSameVariableDefinedInSuite() {
		'''
		suite "pruebas generales" {
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
		suite "pruebas generales" {
			const one = 1
			
			method uno() = 1
			
			test "Uno es one" {
				assert.equals(one, self.uno())
			}
		}
		'''.interpretPropagatingErrors
	}
	
}