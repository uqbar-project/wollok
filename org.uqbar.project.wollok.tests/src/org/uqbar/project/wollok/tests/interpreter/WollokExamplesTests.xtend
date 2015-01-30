package org.uqbar.project.wollok.tests.interpreter

import java.io.File
import org.junit.Test

/**
 * Runs all the examples in the wollok-example project that works as a unit test
 * 
 * @author tesonep
 */
class WollokExamplesTests extends AbstractWollokInterpreterTestCase {
	val path = EXAMPLES_PROJECT_PATH + "/src/"

	@Test
	def void runAllTests() throws Exception {
		new File(path).listFiles[isFile && name.endsWith(".wlk")].forEach[interpretPropagatingErrors]
	}
}
