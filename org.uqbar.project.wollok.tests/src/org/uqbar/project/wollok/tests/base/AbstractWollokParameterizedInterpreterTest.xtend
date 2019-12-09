package org.uqbar.project.wollok.tests.base

import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.^extension.ExtendWith
import org.junit.runners.Parameterized
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Helper class to allow parameterized interpreter tests
 */
@ExtendWith(Parameterized)
abstract class AbstractWollokParameterizedInterpreterTest extends AbstractWollokInterpreterTestCase {

	/**
	 * Inject dependencies into this test. 
	 * This is necessary because @link Parameterized does not allow to define a runner for the child tests.
	 */
	@BeforeEach
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
