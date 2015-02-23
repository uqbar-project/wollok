package org.uqbar.project.wollok.tests.interpreter

import java.io.File
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.WollokDslInjectorProvider

/**
 * Runs all the examples in the wollok-example project that works as a unit test
 * 
 * @author tesonep
 * @author npasserini
 */
@RunWith(Parameterized)
class WollokExamplesTests extends AbstractWollokInterpreterTestCase {
	static val path = EXAMPLES_PROJECT_PATH + "/src/"
	static val libPath = EXAMPLES_PROJECT_PATH + "/src/lib"

	@Parameter(0)
	public File program

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		new File(path).listFiles[isFile && name.endsWith(".wlk")].map[#[it] as Object[]]
	}

	/**
	 * Inject dependencies into this test. This is necessary because @link Parameterized does not allow to define a runner for the child tests.
	 */
	@Before
	def void injectMembers() {
		new WollokDslInjectorProvider().injector.injectMembers(this)
		addLibs()
	}
	
	def void addLibs(){
		new File(libPath).listFiles([isFile && name.endsWith(".wlk")]).forEach[
			it.interpretPropagatingErrors
		]
	}
	
	@Test
	def void runWollok() throws Exception {
		program.interpretPropagatingErrors
	}
}
