package org.uqbar.project.wollok.tests.sanityTests

import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import java.time.format.DateTimeFormatter
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.uqbar.project.wollok.tests.injectors.WollokSanityTestInjectorProvider
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import wollok.lang.WDate

import static org.uqbar.project.wollok.WollokConstants.*
import static wollok.lang.WDate.*

import static extension org.uqbar.project.wollok.utils.StringUtils.*

/**
 * Executes Sanity Tests from wollok-language
 * 
 * Prints output in the console without colors
 * Succeeds if no files have errors. Looks for all .wtest files in sibling wollok-language folder.
 * 
 * @author dodain
 */
@ExtendWith(InjectionExtension)
@InjectWith(WollokSanityTestInjectorProvider) 
class SanityTestCase extends AbstractWollokInterpreterTestCase {
	val path = "../wollok-language/test/sanity"
	
	@Test
	def void run() {
		// TODO: We should find a better way instead of forcing locale
		WDate.FORMATTER = DateTimeFormatter.ofPattern("M/d/yyyy")

		val failed = newArrayList
		Files.walk(Paths.get(path))
			.filter([ path | !Files.isDirectory(path) && path.toString.endsWith(TEST_EXTENSION) ])
			.forEach [ file |
				try {
					new File(file.toString).interpretPropagatingErrors(false)
				} catch (Exception e) {
					failed.add(file.toString)
				}
			]
		assertTrue(failed.isEmpty, '''
		There were «failed.size.singularOrPlural("file", "files")»  with errors in the sanity tests. 
		Check your log for details.
		«failed.join("\n")»
		''')
	}
	
}
