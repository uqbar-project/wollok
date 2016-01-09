package org.uqbar.project.wollok.launch

import com.google.inject.Inject
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

/**
 * Subclasses the wollok evaluator to support tests
 * 
 * // TODO: should we need this subclass ? why don't we just move this code up ?
 * 
 * @author tesonep
 */
class WollokLauncherInterpreterEvaluator extends WollokInterpreterEvaluator {
	
	@Inject
	WollokTestsReporter wollokTestsReporter
	
	// EVALUATIONS (as multimethods)
	override dispatch evaluate(WFile it) { 
		// Files are not allowed to have both a main program and tests at the same time.
		if (main != null) main.eval else {
			wollokTestsReporter.testsToRun(it, tests)
			try {
				tests.fold(null) [a, e|
					resetGlobalState
					e.eval
				]
			}
			finally
				wollokTestsReporter.finished
		}
	}

	def resetGlobalState() {
		interpreter.globalVariables.clear
	}
	
	override dispatch evaluate(WTest test) {
		try {
			wollokTestsReporter.testStart(test)
			val x = test.elements.evalAll
			wollokTestsReporter.reportTestOk(test)
			x
		}
		catch (WollokInterpreterException e) {
			if (e.cause instanceof AssertionException) {
				wollokTestsReporter.reportTestAssertError(test, e.cause as AssertionException, e.lineNumber, e.objectURI)
				null
			}
			else {
				wollokTestsReporter.reportTestError(test, e, e.lineNumber, e.objectURI)
				null
			}
		}
		catch (WollokProgramExceptionWrapper e) {
			// an uncaught wollok-level exception wrapped into java
			wollokTestsReporter.reportTestError(test, e, e.lineNumber, e.URI)
			null
		}
	}
}