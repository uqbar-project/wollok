package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test

import static org.uqbar.project.wollok.semantics.WollokType.*

/**
 * Tests type system inference and checks
 * 
 * @author jfernandes
 */
class TypeSystemTestCase extends AbstractWollokTypeSystemTestCase {

	@Test
	def void testInferSimpleVariableAssignment() {
		''' program p {
			val number = 23
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, 'val number = 23')
		]
	}

	@Test
	def void testInferIndirectVar() {
		''' program p {
			val number
			number = 23
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, 'val number')
		]
	}

	@Test
	def void testInferIndirectAssignedToBinaryExpression() {
		''' program p {
			val number
			val a = 2
			val b = 3
			number = a + b
		}'''.parseAndInfer.asserting [
			assertTypeOf(WInt, 'val number')
		]
	}

	@Test
	def void testIncompatibleTypesInAssignment() {
		''' program p {
			var a = 2
			val b = "aString"
			a = b
		}'''.parseAndInfer.asserting [
			assertIssues("a = b", "Expecting super type of <<Int>> but found <<String>> which is not")
		]
	}
	
	@Test
	def void testClassType() {
		'''
			class Pato {
				method cuack() { 'cuack!' }
		 	program p {
				val pato = new Pato()
				pato.cuack()
			}'''.parseAndInfer.asserting [
			noIssues
			assertTypeOf(classType("Pato"), 'val pato = new Pato()')
		]
	}

}
