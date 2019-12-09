package org.uqbar.project.wollok.tests.lib

import com.google.inject.name.Named
import javax.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.diagnostics.Severity
import org.uqbar.project.wollok.libraries.AbstractWollokLib
import org.uqbar.project.wollok.libraries.WollokLib
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.jupiter.api.Test

/**
 * This test validates that the library is statically correct
 * @author tesonep
 */
class WollokLibraryHealthyTest extends AbstractWollokInterpreterTestCase {

	@Inject
	@Named("standardWollokLib")
	var WollokLib standardWollokLib

	@Test
	def validateLib(){
		val sb = new StringBuilder()

		(standardWollokLib as AbstractWollokLib).getManifest(null).allURIs.forEach[ it.validateSyntax(sb) ]

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