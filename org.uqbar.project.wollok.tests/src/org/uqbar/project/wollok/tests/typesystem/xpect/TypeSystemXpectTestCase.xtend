package org.uqbar.project.wollok.tests.typesystem.xpect

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResource
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.typesystem.AbstractWollokTypeSystemTestCase
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.wollokDsl.WFile
import org.xpect.expectation.IStringExpectation
import org.xpect.expectation.StringExpectation
import org.xpect.parameter.ParameterParser
import org.xpect.runner.LiveExecutionType
import org.xpect.runner.Xpect
import org.xpect.runner.XpectRunner
import org.xpect.runner.XpectSuiteClasses
import org.xpect.xtext.lib.setup.ThisModel
import org.xpect.xtext.lib.setup.ThisResource
import org.xpect.xtext.lib.tests.ValidationTest
import org.xpect.xtext.lib.tests.ValidationTestModuleSetup.ConsumedIssues

/**
 * Test class for extending xpect to have tests on static proposals (content assist)
 * 
 * @author npasserini
 */
@XpectSuiteClasses(#[ValidationTest])
@RunWith(XpectRunner)
class TypeSystemXpectTestCase extends AbstractWollokTypeSystemTestCase {

	@Xpect(liveExecution=LiveExecutionType.FAST)
	@ParameterParser(syntax="'at' node=OFFSET")
	@ConsumedIssues(#[Severity.INFO, Severity.ERROR, Severity.WARNING])
	def void type( //
		@StringExpectation IStringExpectation expectation,
		EObject node,
		@ThisResource XtextResource resource, //
		@ThisModel EObject file
	) {
		tsystemClass = ConstraintBasedTypeSystem
		setupTypeSystem
		tsystem.validate(file as WFile, validator)
		expectation.assertEquals(tsystem.type(node))
	}
}
