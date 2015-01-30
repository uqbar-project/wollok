package org.uqbar.project.wollok.tests.interpreter.examples

import java.io.File
import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Executes the monsters inc example
 * 
 * @author jfernandes
 */
class MonstersIncTestCase extends AbstractWollokInterpreterTestCase {
	val path = EXAMPLES_PROJECT_PATH + "/src/wollok/examples/monstersinc/workspace.wlk"
	
	@Test
	def void run() {
		new File(path).interpretPropagatingErrors
	}
	
}