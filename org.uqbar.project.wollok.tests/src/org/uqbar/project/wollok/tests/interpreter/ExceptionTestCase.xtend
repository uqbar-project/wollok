package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.interpreter.core.WollokObject
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Tests wollok exceptions handling mechanism.
 * 
 * @author jfernandes
 */
class ExceptionTestCase extends AbstractWollokInterpreterTestCase {

	@Test
	def void testErrorMethodOnWollokObject() {
		'''
			class C {
				method foo() {
					self.error("Gently failing!")
				}
			}
			program p {
				try {
					const f = new C()
					f.foo()
				}
				catch e {
					// OK !
					assert.equals("Gently failing!", e.message())
					// assert.equals(f, e.source())
				}
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchWithAReturnStatement() {
		'''
		object cuenta {
			method sacar() {
				try {
					throw new Exception(message = "saldo insuficiente")
				} 
				catch e {
					return 20
				}
			}
		}
		program p {
			assert.equals(20, cuenta.sacar())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchWithAReturnStatementReturningFromTryBodyAndFromCatch() {
		'''
		object cuenta {
			method sacar(c) {
				try {
					if (c > 0)
						throw new Exception(message = "saldo insuficiente")
					return 19
				} 
				catch e {
					return 20
				}
			}
		}
		program p {
			assert.equals(20, cuenta.sacar(10))
			assert.equals(19, cuenta.sacar(0))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void testCatchEvaluationInAShortCutMethod() {
		'''
		object cuenta {
			method sacar(c) = try { 
					if (c > 0) 
						throw new Exception(message = "saldo insuficiente") 
					else 19
				} catch e {
					20
				}
		}
		program p {
			assert.equals(20, cuenta.sacar(10))
			assert.equals(19, cuenta.sacar(0))
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void assertThrowsExceptionFailing() {
		'''
		var a = 0
		assert.throwsExceptionLike(
			new AssertionException(message = "Block { a + 1 } should have failed"),
			{ assert.throwsException({ a + 1 }) }
		)
		'''.test
	}
	
	@Test
	def void testCanCreateExceptionUsingNamedParametersWithoutCause() {
		'''
		object unObjeto {
			method prueba() {
				throw new Exception(message = "Saraza")
			}
		}
		'''.interpretPropagatingErrors
	}
	
}