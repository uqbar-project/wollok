package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

/**
 * 
 * @author npasserini
 */
class SuperInvocationTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testSuperInvocation() {
		'''
			class Golondrina {
				var energia = 100
			
				method energia() {
					return energia
				}
			
				method volar(kms) {
					energia = energia - this.gastoParaVolar(kms) // Invocacion a método que se va a sobreescribir
				}
				
				method gastoParaVolar(kms) {
					return kms
				}
			}
			
			class SeCansaMucho extends Golondrina {
				override method gastoParaVolar(kms) {
					return 2 * super(kms)
				}
			}
			
			program p {
				val pepona = new SeCansaMucho()
				pepona.volar(50)
				assert.that(pepona.energia() == 0) // Gastó el doble de energia
			}
		'''.interpretPropagatingErrors
	}
}
