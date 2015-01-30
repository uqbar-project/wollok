package org.uqbar.project.wollok.tests.parser

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WLibrary

/**
 * Tests that the scope of a variable is the correct one.
 * 
 * @author tesonep
 */
class ScopeTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void shadowing() {
		val model = '''
			class Tren {
			    val vagones = #[]
			
			    def agregarVagon(v) {
			        vagones.add(v)
			    }
			    def getCantidadPasajeros() {
			        vagones.fold(0, [v| v.getCantidadPasajeros()])
			    }
			}
			
			val t = new Tren()
		'''.parse
		model.validate

		val agregarVagon = ((model.body as WLibrary).elements.get(0) as WClass).members.get(1) as WMethodDeclaration
		val getCantidadPasajeros = ((model.body as WLibrary).elements.get(0) as WClass).members.get(2) as WMethodDeclaration
		val v_param = agregarVagon.parameters.get(0) as WParameter
		val msgSend = (getCantidadPasajeros.expression as WBlockExpression).expressions.get(0) as WMemberFeatureCall
		val block = msgSend.memberCallArguments.get(1) as WClosure
		val v_closureParam = block.parameters.get(0)
		val v_usedInClosure = ((block.expression as WBlockExpression).expressions.get(0) as WMemberFeatureCall).memberCallTarget as WVariableReference

		assertNotEquals(v_param, v_closureParam)
		assertNotEquals(v_param, v_usedInClosure.ref)
		assertEquals(v_closureParam, v_usedInClosure.ref)
	}

	@Test
	def void testInObjectLiterals() {
		val model = '''
			val vaca1 = object (
				var peso = 1000
				def engordar(cuanto) {
					peso = peso + cuanto
				}
				def peso() {
					peso
				}
			)
			
			val vaca2 = object(
				var peso = 1000
				def engordar(cuanto) {
					peso = peso + cuanto
				}
				def peso() {
					peso
				}			
			)
			
			vaca1.peso()
			vaca2.peso()
		'''.parse

		val vaca1 = ((model.body as WLibrary).elements.get(0) as WVariableDeclaration).right as WObjectLiteral
		val vaca2 = ((model.body as WLibrary).elements.get(1) as WVariableDeclaration).right as WObjectLiteral
		val peso_vaca1 = (vaca1.members.get(0) as WVariableDeclaration).variable
		val uso_peso_vaca1 = ((vaca1.members.get(2) as WMethodDeclaration).expression as WBlockExpression).expressions.
			get(0) as WVariableReference

		val peso_vaca2 = (vaca2.members.get(0) as WVariableDeclaration).variable
		val uso_peso_vaca2 = ((vaca2.members.get(2) as WMethodDeclaration).expression as WBlockExpression).expressions.
			get(0) as WVariableReference

		assertEquals(peso_vaca1, uso_peso_vaca1.ref)
		assertEquals(peso_vaca2, uso_peso_vaca2.ref)
	}

}
