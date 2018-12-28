package org.uqbar.project.wollok.tests.typesystem

import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem

import static org.uqbar.project.wollok.sdk.WollokDSK.*

class CollectionInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name="{index}: {0}")
	static def Object[] typeSystems() {
		#[
			ConstraintBasedTypeSystem
		]
	}

	@Test
	def void listLiteral() {
		'''
		program p {
			const l = []
		}
		'''.parseAndInfer.asserting [
			assertTypeOfAsString("List<Any>", "l")
		]
	}

	@Test
	def void listLiteralElement() {
		'''
		program p {
			const firstOfNumbers = [1].first()
			const firstOfStrings = ["hola"].first()
		}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(NUMBER), "firstOfNumbers")
			assertTypeOf(classTypeFor(STRING), "firstOfStrings")
		]
	}

	@Test
	def void add() {
		'''
		program p {
			const l = []
			l.add(1)
			const firstOfNumbers = l.first()
		}
		'''.parseAndInfer.asserting [
			assertTypeOf(classTypeFor(NUMBER), "firstOfNumbers")
		]
	}

	@Test
	def void listSelfType() {
		'''
		program p {
			const l = [1,2,3]
			const pares = l.filter({ n => n.even() })
		}
		'''.parseAndInfer.asserting [
			assertTypeOfAsString("List<Number>", "l")
			assertTypeOfAsString("List<Number>", "pares")
		]
	}
	
	@Test
	def void setSelfType() {
		'''
		program p {
			const l = #{1,2,3}
			const pares = l.filter({ n => n.even() })
		}
		'''.parseAndInfer.asserting [
			assertTypeOfAsString("Set<Number>", "l")
			assertTypeOfAsString("Set<Number>", "pares")
		]
	}
	
	@Test
	def void bothSelfType() {
		'''
		program p {
			const l = [1,2,3]
			const lPares = l.filter({ n => n.even() })
			const s = #{"1"}
			const sPares = s.filter({ n => n > "2" })
		}
		'''.parseAndInfer.asserting [
			assertTypeOfAsString("List<Number>", "l")
			assertTypeOfAsString("List<Number>", "lPares")
			assertTypeOfAsString("Set<String>", "s")
			assertTypeOfAsString("Set<String>", "sPares")
		]
	}
}
