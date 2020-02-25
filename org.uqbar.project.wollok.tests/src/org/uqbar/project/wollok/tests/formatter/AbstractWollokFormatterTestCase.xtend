package org.uqbar.project.wollok.tests.formatter

import com.google.inject.Inject
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.serializer.ISerializer
import org.junit.Assert
import org.uqbar.project.wollok.tests.interpreter.WollokParseHelper
import org.uqbar.project.wollok.wollokDsl.WAssignment

/**
 * Tests wollok code formatter
 * 
 * @author jfernandes
 * @author tesonep
 */
abstract class AbstractWollokFormatterTestCase {
	@Inject protected extension WollokParseHelper
	@Inject protected extension ISerializer

	def assertFormatting(String program, String expected) {
		// program.parse.eContents.show(1)
		Assert.assertEquals(expected,
        program.parse.serialize(SaveOptions.newBuilder.format().getOptions()))		
	}
	
	def void show(EList<EObject> list, int tabs) {
		val indentation = (1..tabs).map [ '  ' ].join
		println(indentation + list.map [ show ])
		list.forEach [ eContents.show(tabs + 1) ]
	}

	def dispatch show(EObject e) {
		e.class.simpleName
	}
	
	def dispatch show(WAssignment a) {
		"Assignment " + a.feature.ref.name
	}

}
