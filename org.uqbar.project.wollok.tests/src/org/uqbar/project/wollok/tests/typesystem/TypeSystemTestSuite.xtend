package org.uqbar.project.wollok.tests.typesystem

import org.junit.Ignore
import org.junit.runner.RunWith
import org.junit.runners.Suite

/**
 * Groups together all type systems test cases
 * 
 * @author jfernandes
 */
@RunWith(Suite)
@Suite.SuiteClasses(
   TypeSystemTestCase,
   IfTypeInferenceTestCase,
   MethodTypeInferenceTestCase,
   InheritanceTypeInferenceTestCase,
   LiteralsInferenceTestCase,
   ConstructorTypeInferenceTestCase
)
@Ignore
class TypeSystemTestSuite {
	
}