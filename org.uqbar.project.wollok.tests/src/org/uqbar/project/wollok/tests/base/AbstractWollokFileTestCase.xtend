package org.uqbar.project.wollok.tests.base

import java.io.File
import org.junit.Test
import org.junit.runners.Parameterized.Parameter

/**
 * Absrtact base class for wollok tests that run a list of wollok
 * files (instead of coding in java)
 * 
 * @author jfernandes
 */
abstract class AbstractWollokFileTestCase extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public File program
	
	def static Iterable<Object[]> files(String path) {
		path.listWollokPrograms.asParameters
	}
	
	@Test
	def void runWollok() throws Exception {
		program.interpretPropagatingErrors
	}
}