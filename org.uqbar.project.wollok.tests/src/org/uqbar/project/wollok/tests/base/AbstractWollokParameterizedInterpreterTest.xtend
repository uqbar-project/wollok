package org.uqbar.project.wollok.tests.base

import org.junit.Before
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

/**
 * Helper class to allow parameterized interpreter tests
 */
@RunWith(Parameterized)
abstract class AbstractWollokParameterizedInterpreterTest extends AbstractWollokInterpreterTestCase {

	/**
	 * Inject dependencies into this test. 
	 * This is necessary because @link Parameterized does not allow to define a runner for the child tests.
	 */
	@Before
	override setUp() {
		new WollokTestInjectorProvider().injector.injectMembers(this)
		super.setUp
	}

	/**
	 * Converts an Iterable of Iterables into an Iterable<Object[]> as required by the Parameterized runner
	 */
	static def asParameters(Iterable<?> parameters) {
		parameters.map[#[it] as Object[]]
	}
}
