package org.uqbar.project.wollok.tests.interpreter.imports

import org.junit.Ignore
import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Test the different combinations and functionality of imports.
 * 
 * @author jfernandes
 * @author tesonep
 * 
 */
class ImportsTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	@Ignore // No puedo armar una gramática válida que funcione. 
	def void mustUseFullNameToReferenceObjectFromSameFileButDifferentPackage() {
		'''
			package aves {
				object pepita {
					method volar() { "vuelo vuelo" }
				}	
			}
			package entrenadores {
				object mostaza {
					method entrenar() {
						aves.pepita.volar()        // NO DEBERIA FALLAR !: creo que no tenemos soporte en la gramática para hacer esto !
					}
				}	
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testReferenceByFQNWithoutImport() {
		// Este test no lo pude llevar a wollok-cli => no reconoce a b.Golondrina sin el import
		#[
		'b' -> '''
			class Golondrina  {
			    method volar(kms) {
			        console.println("flying...")
			    }
			}
		''',
		'programa' -> '''
			program zuper {
			        const pepona = new b.Golondrina()
			}
		'''
		].interpretAsFilesPropagatingErrors
	}

	@Test
	def void testSameNameTestAndWlk() {
		try {
			#['aves' -> '''
				object pepita {
					method energia() = 1
				}
			 ''',
			  'aves' -> '''
			    test "pepita energia" {
			    	assert.equals(pepita.energia(), 1)
			    }
			  '''
			].interpretAsFilesPropagatingErrors
			fail("Should have failed missing import to pepita")
		} catch (AssertionError e) {
		}
	}

}
