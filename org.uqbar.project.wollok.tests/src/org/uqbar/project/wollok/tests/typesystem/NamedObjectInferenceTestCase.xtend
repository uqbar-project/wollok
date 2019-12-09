package org.uqbar.project.wollok.tests.typesystem

import org.junit.Ignore
import org.junit.jupiter.api.Test

import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * Test cases for type inference of named objects, including imported ones.
 * 
 * @author npasserini
 */
class NamedObjectInferenceTestCase extends AbstractWollokTypeSystemTestCase {

//	@Parameters(name="{index}: {0}")
//	static def Object[] typeSystems() {
//		#[ConstraintBasedTypeSystem]
//	}

	@Test
	def void typeOfCoreWKO() {
		'''
			program p {
				console
			}
		'''.parseAndInfer.asserting [
			assertTypeOf(objectTypeFor(CONSOLE), 'console')
		]
	}

	@Test
	def void typeOfNamedObjectReference() {
		'''
			object pepita {}
			
			program p {
				var ref = pepita
			}
		'''.parseAndInfer.asserting [
			assertTypeOfAsString("pepita", "ref")
		]
	}

	@Test
	def void typeOfImportedNamedObjectReference() {
		#['''
			object pepita {}
		''', '''
			import __synthetic0.pepita
					
			program p {
				var ref = pepita
			}
		'''].parseAndInfer.asserting [
			assertTypeOfAsString("pepita", "ref")
		]
	}

	@Test
	def void typeOfImportedNamedObjectReferenceReverseOrder() {
		#['''
			import __synthetic1.pepita
					
			program p {
				var ref = pepita
			}
		''', '''
			object pepita {}
		'''].parseAndInferAll.head.asserting [
			assertTypeOfAsString("pepita", "ref")
		]
	}

	@Test
	def void typeOfWildcardImportedNamedObjectReference() {
		#['''
			object pepita {}
		''', '''
			import __synthetic0.*
					
			program p {
				var ref = pepita
			}
		'''].parseAndInfer.asserting [
			assertTypeOfAsString("pepita", "ref")
		]
	}

	@Test
	@Ignore 
	def void typeOfImportedUnexistentNamedObjectReference() {
		#['''
			object pepita {}
		''', '''
			import __synthetic0.pepita
					
			program p {
				var ref = pepona
			}
		'''].parseAndInfer.asserting [
			// TODO Assert adequate error is informed.
		]
	}
}
