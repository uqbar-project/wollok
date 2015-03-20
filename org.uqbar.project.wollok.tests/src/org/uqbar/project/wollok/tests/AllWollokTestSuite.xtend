package org.uqbar.project.wollok.tests

import org.junit.Ignore
import org.junit.runner.RunWith
import org.junit.runners.Suite
import org.uqbar.project.wollok.tests.interpreter.ClosureTestCase
import org.uqbar.project.wollok.tests.interpreter.ExceptionTestCase
import org.uqbar.project.wollok.tests.interpreter.ListTestCase
import org.uqbar.project.wollok.tests.interpreter.MixedNumberTypesOperations
import org.uqbar.project.wollok.tests.interpreter.MultiOpAssignTestCase
import org.uqbar.project.wollok.tests.interpreter.NamedObjectsTestCase
import org.uqbar.project.wollok.tests.interpreter.PolymorphismTestCase
import org.uqbar.project.wollok.tests.interpreter.PostFixOperationTestCase
import org.uqbar.project.wollok.tests.interpreter.SuperInvocationTest
import org.uqbar.project.wollok.tests.interpreter.TypeSystemTestCase
import org.uqbar.project.wollok.tests.interpreter.UnusedVariableTest
import org.uqbar.project.wollok.tests.interpreter.WollokExamplesTests
import org.uqbar.project.wollok.tests.natives.NativeTestCase

/**
 * Holds all wollok testcases to be able to run them all together
 * in a single "run as".
 * 
 * @author jfernandes
 */
@RunWith(Suite)
@Suite.SuiteClasses(
//   TypeSystemTestSuite,
   MixedNumberTypesOperations,
   PolymorphismTestCase,
   SuperInvocationTest,
   TypeSystemTestCase,
   UnusedVariableTest,
   WollokExamplesTests,
   MultiOpAssignTestCase,
   PostFixOperationTestCase,
   ExceptionTestCase,
   NativeTestCase,
   ListTestCase,
   ClosureTestCase,
   NamedObjectsTestCase
)
@Ignore
class AllWollokTestSuite {
	
}