package org.uqbar.project.wollok.tests.base

import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import org.junit.Before
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.uqbar.project.wollok.WollokDslInjectorProvider
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

import static extension org.uqbar.project.wollok.WollokConstants.*

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
		new WollokDslInjectorProvider().injector.injectMembers(this)
		super.setUp
	}

	/**
	 * Converts a Iterable of Iterables into an Iterable<Object[]> as required by the Parameterized runner
	 */
	def static asParameters(Iterable<?> parameters) {
		parameters.map[#[it] as Object[]]
	}
	
	def static dispatch Iterable<File> listWollokPrograms(String path) {
		new File(path).listWollokPrograms
	}
	
	def static dispatch Iterable<File> listWollokPrograms(File it) {
		println("Checking " + absolutePath)
		if (file) {
			if(name.isWollokExtension && !ignore(it))
				#[it]
			else
				#[]
		} 
		else {
			if (listFiles == null || listFiles.length == 0) #[]
			else listFiles.map[listWollokPrograms].flatten
		}
	}
	
	def static ignore(File file) {
		var BufferedReader reader = null
		try {
			reader = new BufferedReader(new FileReader(file))
			val r = reader.readLine.contains("@test IGNORE")
			if (r) println("IGNORING " + file.name)
			r
		}
		finally {
			if (reader != null)
				reader.close
		} 
	}
}
