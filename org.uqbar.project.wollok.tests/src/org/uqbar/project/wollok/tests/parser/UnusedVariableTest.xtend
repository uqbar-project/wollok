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
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

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
			
			    method agregarVagon(v) {
			        vagones.add(v)
			    }
			    method getCantidadPasajeros() {
			        vagones.fold(0, [v| v.getCantidadPasajeros()])
			    }
			}
			
			program shadowing {
				val t = new Tren()
			}
		'''.parse
		model.validate

		val tren = model.elements.get(0) as WClass
		val agregarVagon = tren.members.get(1) as WMethodDeclaration
		val getCantidadPasajeros = tren.members.get(2) as WMethodDeclaration
		val v_param = agregarVagon.parameters.get(0) as WParameter
		val msgSend = (getCantidadPasajeros.expression as WBlockExpression).expressions.get(0) as WMemberFeatureCall
		val block = msgSend.memberCallArguments.get(1) as WClosure
		val v_closureParam = block.parameters.get(0)
		val v_usedInClosure = ((block.expression as WBlockExpression).expressions.get(0) as WMemberFeatureCall).
			memberCallTarget as WVariableReference

		assertNotEquals(v_param, v_closureParam)
		assertNotEquals(v_param, v_usedInClosure.ref)
		assertEquals(v_closureParam, v_usedInClosure.ref)
	}

	@Test
	def void testInObjectLiterals() {
		val model = '''
			program {
				val vaca1 = object {
					var peso = 1000
					method engordar(cuanto) {
						peso = peso + cuanto
					}
					method peso() {
						return peso
					}
				}
				
				val vaca2 = object {
					var peso = 1000
					method engordar(cuanto) {
						peso = peso + cuanto
					}
					method peso() {
						return peso
					}			
				}
				
				vaca1.peso()
				vaca2.peso()
			}
		'''.parse

		val program = model.main as WProgram
		val vaca1 = (program.elements.get(0) as WVariableDeclaration).right as WObjectLiteral
		val vaca2 = (program.elements.get(1) as WVariableDeclaration).right as WObjectLiteral
		
		val def_peso = [ WObjectLiteral unaVaca | 
			(unaVaca.members.get(0) as WVariableDeclaration).variable
		]
		
		val ref_peso = [ WObjectLiteral unaVaca |
			((((unaVaca.members.get(2) as WMethodDeclaration)
				.expression as WBlockExpression)
				.expressions.get(0) as WReturnExpression)
				.expression as WVariableReference)
				.ref
		]
		
		assertEquals(def_peso.apply(vaca1), ref_peso.apply(vaca1))
		assertEquals(def_peso.apply(vaca2), ref_peso.apply(vaca2))
	}
}
