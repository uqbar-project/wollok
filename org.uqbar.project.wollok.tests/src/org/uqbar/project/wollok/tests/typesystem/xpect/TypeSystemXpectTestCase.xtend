package org.uqbar.project.wollok.tests.typesystem.xpect

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xpect.XpectImport
import org.eclipse.xpect.expectation.IStringExpectation
import org.eclipse.xpect.expectation.StringExpectation
import org.eclipse.xpect.parameter.ParameterParser
import org.eclipse.xpect.runner.LiveExecutionType
import org.eclipse.xpect.runner.Xpect
import org.eclipse.xpect.runner.XpectRunner
import org.eclipse.xpect.runner.XpectSuiteClasses
import org.eclipse.xpect.xtext.lib.setup.ThisModel
import org.eclipse.xpect.xtext.lib.setup.ThisResource
import org.eclipse.xpect.xtext.lib.tests.ValidationTest
import org.eclipse.xpect.xtext.lib.tests.ValidationTestModuleSetup.ConsumedIssues
import org.eclipse.xpect.xtext.lib.util.XtextOffsetAdapter.IEStructuralFeatureAndEObject
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResource
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.typesystem.AbstractWollokTypeSystemTestCase
import org.uqbar.project.wollok.tests.typesystem.WollokTypeSystemTestModule
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.typesystem.TypeSystemUtils.*
import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*

/**
 * Test class for extending xpect to have tests on static proposals (content assist)
 * 
 * @author npasserini
 */
@RunWith(XpectRunner)
@XpectSuiteClasses(#[ValidationTest])
@XpectImport(WollokTypeSystemTestModule)
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

		var method = target.EObject.method
		expectation.assertEquals(method.functionType(typeSystem))
	}

	def dispatch method(EObject object) {
		throw new IllegalArgumentException(object.debugInfo)
	}

	def dispatch method(WMemberFeatureCall messageSend) {
		val receiverType = typeSystem.type(messageSend.memberCallTarget) as ConcreteType
		receiverType.lookupMethod(messageSend.feature, messageSend.memberCallArguments)
	}

	def dispatch method(WMethodDeclaration method) {
		method
	}
	
}

