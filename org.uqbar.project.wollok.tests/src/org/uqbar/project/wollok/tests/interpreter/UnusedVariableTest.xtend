package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WProgram

/**
 * Tests that the validation of unused variables works as expected.
 * 
 * @author tesonep
 */
class UnusedVariableTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testUnusedInObjectLiteral() {
		val model = ''' program p {
			val vaca1 = object {
				var peso = 1000
				method engordar(cuanto) {
					peso = peso + cuanto
				}
				method peso() {
					peso
				}
			}
			
			val vaca2 = object {
				var peso = 1000
				method engordar(cuanto) {
					peso = peso + cuanto
				}
				method peso() {
					peso
				}			
			}
			
			vaca1.peso()
			vaca2.peso()
		}
		'''.interpretPropagatingErrors

		val vaca1 = ((model.main as WProgram).elements.get(0) as WVariableDeclaration).right as WObjectLiteral
		val vaca2 = ((model.main as WProgram).elements.get(1) as WVariableDeclaration).right as WObjectLiteral
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
