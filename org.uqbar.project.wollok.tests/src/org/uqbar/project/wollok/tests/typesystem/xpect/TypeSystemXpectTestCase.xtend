package org.uqbar.project.wollok.tests.typesystem.xpect

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResource
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.typesystem.AbstractWollokTypeSystemTestCase
import org.uqbar.project.wollok.tests.typesystem.WollokTypeSysteTestModule
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.xpect.XpectImport
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
import org.xpect.xtext.lib.util.XtextOffsetAdapter.IEStructuralFeatureAndEObject

import static extension org.uqbar.project.wollok.typesystem.TypeSystemUtils.*

/**
 * Test class for extending xpect to have tests on static proposals (content assist)
 * 
 * @author npasserini
 */
@RunWith(XpectRunner)
@XpectSuiteClasses(#[ValidationTest])
@XpectImport(WollokTypeSysteTestModule)
class TypeSystemXpectTestCase extends AbstractWollokTypeSystemTestCase {
	@Inject TypeSystem typeSystem

	@Xpect(liveExecution=LiveExecutionType.FAST)
	@ParameterParser(syntax="'at' arg1=OFFSET")
	@ConsumedIssues(#[Severity.INFO, Severity.ERROR, Severity.WARNING])
	def void type( //
		@StringExpectation IStringExpectation expectation,
		EObject target,
		@ThisResource XtextResource resource,
		@ThisModel EObject file
	) {
		expectation.assertEquals(typeSystem.type(target))
	}

	@Xpect(liveExecution=LiveExecutionType.FAST)
	@ParameterParser(syntax="'at' arg1=OFFSET")
	@ConsumedIssues(#[Severity.INFO, Severity.ERROR, Severity.WARNING])
	def void methodType( //
		@StringExpectation IStringExpectation expectation,
		IEStructuralFeatureAndEObject target,
		@ThisResource XtextResource resource,
		@ThisModel EObject file
	) {
		val messageSend = target.EObject as WMemberFeatureCall
		val receiverType = tsystem.type(messageSend.memberCallTarget) as ConcreteType
		val method = receiverType.lookupMethod(messageSend.feature, messageSend.memberCallArguments)
		expectation.assertEquals(method.functionType(tsystem))
	}
}
