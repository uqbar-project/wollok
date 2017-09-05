package org.uqbar.project.wollok.tests.validations

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

class ReceiverMissingTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testValidClass() {
		val model = '''
			class Tren {
			    method getCantidadPasajeros() {
			        return 3
			    }
			    method dobleDeCantidadPasajeros() {
			    	return self.getCantidadPasajeros() * 2
			    }
			}			
		'''.parse
		model.assertNoErrors
	}

	@Test
	def void testReceiverMissingFeatureCall() {
		val model = '''
			class Tren {
			    method getCantidadPasajeros() {
			        return 3
			    }
			    method dobleDeCantidadPasajeros() {
			    	return getCantidadPasajeros() * 2
			    }
			}			
		'''.parse
		model.assertError(model.eClass, "RECEIVER_MISSING")
		
		//(, "RECEIVER_MISSING")
	}
	
}