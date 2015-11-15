package org.uqbar.project.wollok.launch

import com.google.inject.Inject
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

class WollokLauncherInterpreterEvaluator extends WollokInterpreterEvaluator {
	
	@Inject
	WollokTestsReporter wollokTestsReporter
	
		// EVALUATIONS (as multimethods)
	override dispatch Object evaluate(WFile it) { 
		// Files should are not allowed to have both a main program and tests at the same time.
		if (main != null) main.eval else {
			wollokTestsReporter.testsToRun(it, tests)
			tests.evalAll
		}
	}
	
	
	override dispatch Object evaluate(WTest test) {
		try {
			wollokTestsReporter.testStart(test)
			val x = test.elements.evalAll
			wollokTestsReporter.reportTestOk(test)
			x
		}
		catch(WollokInterpreterException e) {
			if (e.cause instanceof AssertionException) {
				wollokTestsReporter.reportTestAssertError(test, e.cause as AssertionException, e.lineNumber, e.ObjectURI)
				null
			}
			else {
				wollokTestsReporter.reportTestError(test, e, e.lineNumber, e.ObjectURI)
				null
			}
		}
	}
}