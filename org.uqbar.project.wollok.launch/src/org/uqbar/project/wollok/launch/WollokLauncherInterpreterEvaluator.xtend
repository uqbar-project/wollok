package org.uqbar.project.wollok.launch

import com.google.inject.Inject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import static extension org.uqbar.project.wollok.launch.tests.WollokExceptionUtils.*

/**
 * Subclasses the wollok evaluator to support tests
 * 
 * @author tesonep
 */
class WollokLauncherInterpreterEvaluator extends WollokInterpreterEvaluator {
	
	@Inject @Accessors
	WollokTestsReporter wollokTestsReporter
	
	// EVALUATIONS (as multimethods)
	override dispatch evaluate(WFile it) {
		// Files are not allowed to have both a main program and tests at the same time.
		if (main != null) main.eval else {
			val isASuite = tests.empty
			val testsToRun = if (isASuite) suite.tests else tests
			val suiteName = if (isASuite) suite.name else null
			wollokTestsReporter.testsToRun(suiteName, it, testsToRun)
			try {
				testsToRun.fold(null) [a, e|
					resetGlobalState
					if (isASuite) suite.members.evalAll
					e.eval
				]
			}
			finally {
				wollokTestsReporter.finished
			}
		}
	}

	def resetGlobalState() {
		interpreter.globalVariables.clear
	}
	
	override dispatch evaluate(WTest test) {
		try {
			//wollokTestsReporter.testStart(test)
			val x = test.elements.evalAll
			wollokTestsReporter.reportTestOk(test)
			x
		}
		catch (Exception e) {
			if (e.isAssertionException) {
				wollokTestsReporter.reportTestAssertError(test, e.generateAssertionError, e.lineNumber, e.URI)
				null
			} else {
				wollokTestsReporter.reportTestError(test, e, e.lineNumber, e.URI)
				null
			}
		}
	}
}
