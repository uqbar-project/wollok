package org.uqbar.project.wollok.tests.lib

import javax.inject.Inject
import org.eclipse.emf.common.util.URI
import org.junit.Test
import org.uqbar.project.wollok.manifest.WollokManifestFinder
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.eclipse.xtext.diagnostics.Severity

/**
 * This test validates that the library is statically correct
 * @author tesonep
 */
class WollokLibraryHealthyTest extends AbstractWollokInterpreterTestCase {

	@Inject WollokManifestFinder manifestFinder

	@Test
	def validateLib(){
		//TODO esto antes usaba un resourcet vacio
		val allManifests = manifestFinder.allManifests(null)
		val sb = new StringBuilder

		allManifests.forEach[ manifest |
			manifest.allURIs.forEach[ it.validateSyntax(sb) ]
		]

		if (sb.length > 0) {
			val errorText = sb.toString
			throw new AssertionError( "Errors: " + errorText.split(System.lineSeparator).size + System.lineSeparator + errorText)
		}
	}
	
	def void validateSyntax(URI uri, StringBuilder sb){
		val resource = resourceSet.getResource(uri, true)
		resource.load(#{})
		val issues = resource.validate
		
		issues
			.filter[severity == Severity.ERROR && code != 'OBJECT_NAME_MUST_START_LOWERCASE']
			.forEach[ sb.append(severity).append(":").append(message).append(" ").append(uri).append(":").append(lineNumber).append(System.lineSeparator) ]
	}
}