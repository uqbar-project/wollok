package org.uqbar.project.wollok.tests.sanityTests

import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import java.util.Map
import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

import static org.uqbar.project.wollok.WollokConstants.*

/**
 * Executes Sanity Tests from wollok-language
 * 
 * @author dodain
 */
class SanityTestCase extends AbstractWollokInterpreterTestCase {
	val path = "../wollok-language/test/sanity"
	
	@Test
	def void run() {
		val Map<String, AssertionError> allErrors = newHashMap
		// TODO: Meter Logger.log
		println('''
		===================================================================================
		                          BEGIN SANITY TESTS
		===================================================================================
		''')
		Files.walk(Paths.get(path))
			.filter([ path | !Files.isDirectory(path) && path.toString.endsWith(TEST_EXTENSION) ])
			.forEach [ file |
				try {
					new File(file.toString).interpretPropagatingErrors(false)
					println('''√ OK «file»''')
				} catch (AssertionError e) {
					allErrors.put(file.toString, e)
					println(
						'''
						✗ ERRORED «file»
							«e.message»
						'''
					)
				}
			]
		println('''
		===================================================================================
		                           END SANITY TESTS
		===================================================================================
		''')			
		assertEquals(newHashMap, allErrors)
	}
	
}
