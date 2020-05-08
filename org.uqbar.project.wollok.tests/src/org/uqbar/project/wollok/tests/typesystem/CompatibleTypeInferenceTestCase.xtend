package org.uqbar.project.wollok.tests.typesystem

import org.eclipse.emf.ecore.EObject
import org.junit.Test
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall

class CompatibleTypeInferenceTestCase extends AbstractWollokTypeSystemTestCase {

	@Parameters(name="{index}: {0}")
	static def Object[] typeSystems() {
		#[
			ConstraintBasedTypeSystem
		]
	}

	@Test
	def void variableWithBasicTypes() {
		'''
			program {
				var x = ""
				x = 0
			}
		'''.parseAndInfer.asserting [
			findByText("x").assertIncompatibleTypesIssue("String", "Number")
			assertTypeOfAsString("(Number|String)", "x")
		]
	}
		
	@Test
	def void variableWithWKOs() {
		'''
			object obj1 { }
			object obj2 { }
			program {
				var x = obj1
				x = obj2
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertTypeOfAsString("(obj1|obj2)", "x")
		]
	}
	

	@Test
	def void variableWithBasicTypeAndWKO() {
		'''
			object obj { }
			program {
				var x = 0
				x = obj
			}
		'''.parseAndInfer.asserting [
			noIssues
			assertTypeOfAsString("(Number|obj)", "x")
		]
	}
	
	@Test
	def void parameterType() {
		'''
			object testing {
				method test1() {
					obj.boolean("")
				} 				
			}
			object obj {
				method boolean(bool) { return if (bool) 2 else 3 }
			}
		'''.parseAndInfer.asserting [
			findByText('''""''').assertIncompatibleTypesIssue("String", "Boolean")
			assertMethodSignature("(Boolean) => Number", "obj.boolean")
		]
	}
	
	@Test
	def void returnType() {
		'''
			object obj {
				var bool
				method boolean() { return if (bool) 2 else "error" }
			}
		'''.parseAndInfer.asserting [
			findByText('''if (bool) 2 else "error"''').assertIncompatibleTypesIssue("String", "Number")
			assertMethodSignature("() => (Number|String)", "obj.boolean")
		]
	}

	@Test
	def void methodParamVarType() {
		'''
			program {
				const n = 0
				const s = ""
				assert.equals(n, s)
			}
		'''.parseAndInfer.asserting [
			findByText("assert.equals(n, s)", WMemberFeatureCall).assertIncompatibleTypesIssue("String", "Number")
		]
	}
	
	def assertIncompatibleTypesIssue(EObject element, String type1, String type2) {
		element.assertAnyIssueInElement(
				'''Type system: expected <<«type1»>> but found <<«type2»>>''',
				'''Type system: expected <<«type2»>> but found <<«type1»>>'''
			)
	}
	
}
