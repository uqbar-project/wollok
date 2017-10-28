package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

/**
 * author dodain
 */
class PropertiesQuickFixTest extends AbstractWollokQuickFixTestCase {

	@Test
	def testRemovePropertyInMethodLocalVariable(){
		val initial = #['''
			class MyClass{
				method someMethod(){ 
					property var hello = "hola"
				}
			}
		''']

		val result = #['''
			class MyClass{
				method someMethod(){ 
					 var hello = "hola"
				}
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_remove_property_definition_name)
	}

	//FALTAN MAS METODOS QUE PRUEBEN EL REMOVE EN TESTS, O CONSTRUCTORES
	//FALTA SUGERIR QUE AGREGUE CUANDO ENVIAS UN MENSAJE, TENES UNA VARIABLE Y NO ES PROPERTY
	//FALTA CORREGIR EL DELETETOKEN QUE LE PONE UN ESPACIO
}