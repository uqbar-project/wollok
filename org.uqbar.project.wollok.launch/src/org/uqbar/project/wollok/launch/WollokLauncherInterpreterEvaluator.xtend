package org.uqbar.project.wollok.launch

import com.google.inject.Inject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest

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
			val isASuite = tests.empty && suite != null
			var testsToRun = tests
			var String suiteName = null
			if (isASuite) {
				suiteName = suite.name
				testsToRun = suite.tests
			}
			wollokTestsReporter.testsToRun(suiteName, it, testsToRun)
			try {
				testsToRun.fold(null) [a, e|
					resetGlobalState
					if (isASuite) {
						val WollokObject suiteObject = new WollokObject(interpreter, suite)
						suite.members.evalAll
						interpreter.performOnStack(e, suiteObject, [ | suiteObject ])
					} else {
						e.eval
					}
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
			val testResult = test.elements.evalAll
			wollokTestsReporter.reportTestOk(test)
			testResult
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
