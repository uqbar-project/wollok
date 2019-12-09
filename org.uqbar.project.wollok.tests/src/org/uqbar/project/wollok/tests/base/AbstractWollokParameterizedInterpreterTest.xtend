package org.uqbar.project.wollok.tests.base

import org.junit.jupiter.api.BeforeEach
import org.junit.runners.Parameterized
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.jupiter.params.provider.Arguments

/**
 * Helper class to allow parameterized interpreter tests
 */

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

//	/**
//	 * Converts an Iterable of Iterables into an Iterable<Object[]> as required by the Parameterized runner
//	 */
//	static def asParameters(Iterable<?> parameters) {
//		parameters.map[#[it] as Object[]]
//	}

//	/**
//	 * Converts an Iterable of Iterables into an Iterable<Arguments> as required by the Junit jupiter Parameterized runner
//	 */
	static def asArguments(Iterable<?> parameters) {
		parameters.map[Arguments.of(it)].toList
	}
}