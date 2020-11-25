package org.uqbar.project.wollok.launch

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WSuite
import org.uqbar.project.wollok.wollokDsl.WTest

import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static extension org.uqbar.project.wollok.launch.tests.WollokExceptionUtils.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * 
 * Subclasses the wollok evaluator to support tests
 * 
 * @author tesonep
 * @author dodain -- describe development + single test with only
 * 
 */
class WollokLauncherInterpreterEvaluator extends WollokInterpreterEvaluator {

	@Inject @Accessors
	WollokTestsReporter wollokTestsReporter

	// EVALUATIONS (as multimethods)
	override dispatch evaluate(WFile it) {
		// Files are not allowed to have both a main program and tests at the same time.
		if (main !== null)
			main.eval
		else {
			wollokTestsReporter.started
			wollokTestsReporter.folderStarted(null)
			runTestFile
			wollokTestsReporter.folderFinished
			wollokTestsReporter.finished
			null
		}
	}

	def void runTestFile(WFile it){
		if(!tests.empty) {
			val testsToRun = tests.detectTestsToRun
			wollokTestsReporter.testsToRun(null, it, testsToRun)
			testsToRun.forEach [ test |
				resetGlobalState
				test.eval
			]
		}
						
		suites.forEach [suite |
			val testsToRun = suite.tests.detectTestsToRun
			val String suiteName = suite.name				
			wollokTestsReporter.testsToRun(suiteName, it, testsToRun)
			testsToRun.forEach [ test |
				resetGlobalState
				test.evalInSuite(suite)
			]
		]
	}
		
	def EList<WTest> detectTestsToRun(EList<WTest> tests) {
		val onlyTest = tests.findFirst [ only !== null ]
		if (onlyTest === null) tests else new BasicEList(#[onlyTest])
	}
	
	override evaluateAll(List<EObject> eObjects, String folder) {
		wollokTestsReporter.started
		wollokTestsReporter.folderStarted(folder ?: "several-files")	

		eObjects.forEach [ eObject |
			val file = eObject as WFile
			wollokTestsReporter.groupStarted(file.toString)
			interpreter.initStack
			interpreter.generateStack(eObject)
			file.runTestFile
			wollokTestsReporter.groupFinished(file.toString)
		]
		wollokTestsReporter.folderFinished
		wollokTestsReporter.finished
		null
	}
	
	def WollokObject evalInSuite(WTest test, WSuite suite) {
		// If in a suite, we should create a suite wko so this will be our current context to eval the tests
		try {
			val suiteObject = new SuiteBuilder(suite, interpreter).forTest(test).build
			interpreter.performOnStack(test, suiteObject, [ |
				test.eval
			])
		} catch (Exception e) {
			handleExceptionInTest(e, test)
		} 
	}

	def resetGlobalState() {
		interpreter.globalVariables.clear
	}

	override dispatch evaluate(WTest test) {
		try {
			wollokTestsReporter.testStarted(test)
			test.elements.forEach [ expr |
				interpreter.performOnStack(expr, currentContext) [ | expr.eval ]
			]
			wollokTestsReporter.reportTestOk(test)
			null
		} catch (Exception e) {
			handleExceptionInTest(e, test)
		}
	}

	protected def WollokObject handleExceptionInTest(Exception e, WTest test) {
		if (e.isAssertionException) {
			wollokTestsReporter.reportTestAssertError(test, e.generateAssertionError, e.lineNumber, e.URI)
		} else {
			wollokTestsReporter.reportTestError(test, e, e.lineNumber, e.URI)
		}
		null
	}

}

class SuiteBuilder {
	WSuite suite
	WTest test
	WollokInterpreter interpreter

	new(WSuite suite, WollokInterpreter interpreter) {
		this.suite = suite
		this.interpreter = interpreter
	}

	def forTest(WTest test) {
		this.test = test
		this
	}

	def build() {
		// Suite -> suite wko
		val suiteObject = new WollokObject(interpreter, suite)
		// Declaring suite variables as suite wko instance variables
		suite.variableDeclarations.forEach [ attribute |
			suiteObject.addMember(attribute)
			suiteObject.initializeAttribute(attribute)
		]
		if (suite.initializeMethod !== null) {
			interpreter.performOnStack(test, suiteObject, [| interpreter.eval(suite.initializeMethod.expression) ])			
		}
		if (test !== null) {
			// Now, declaring test local variables as suite wko instance variables
			test.variableDeclarations.forEach[ attribute |
				suiteObject.addMember(attribute)
			]
		}
		suiteObject
	}

}
