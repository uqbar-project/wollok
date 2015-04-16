package org.uqbar.project.wollok.tests.interpreter.collections

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * @author tesonep
 */
class RemoveTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testSuperInvocation() { #['''
		object pajarera{
			val pajaros = #[]
			method agregar(unPajaro){
				pajaros.add(unPajaro)
			}
			method quitar(unPajaro){
				pajaros.remove(unPajaro)
			}
			method cantidad(){
				return pajaros.size()
			}
		}
		
		object pepita{
			
		}
		''',
		'''
		program p {
			pajarera.agregar(pepita)
			pajarera.quitar(pepita)
			this.assert(pajarera.cantidad() == 0)
		}'''].interpretPropagatingErrors
	}
}
