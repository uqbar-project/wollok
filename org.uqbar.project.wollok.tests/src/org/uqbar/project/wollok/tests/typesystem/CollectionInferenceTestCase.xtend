package org.uqbar.project.wollok.tests.typesystem

import org.junit.Ignore
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
			assertTypeOf(classTypeFor(LIST), "l")
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
	@Ignore
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
}
