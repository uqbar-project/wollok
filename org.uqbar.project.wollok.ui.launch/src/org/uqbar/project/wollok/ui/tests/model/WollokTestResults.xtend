package org.uqbar.project.wollok.ui.tests.model

import com.google.inject.Singleton
import java.util.List
import java.util.Observable
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.errorHandling.StackTraceElementDTO
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier
import org.uqbar.project.wollok.launch.tests.WollokResultTestDTO
import org.uqbar.project.wollok.launch.tests.WollokTestInfo
import org.uqbar.project.wollok.ui.console.RunInUI

/**
 * This class represents the model of the results of an execution.
 */
 @Singleton
class WollokTestResults extends Observable implements WollokRemoteUITestNotifier { 

	boolean shouldShowOnlyFailuresAndErrors = false
		
	@Accessors
	var WollokTestContainer container
	
	override assertError(String testName, String message, StackTraceElementDTO[] stackTrace, int lineNumber, String resource) {
		testByName(testName).endedAssertError(message, stackTrace, lineNumber, resource)
		
		this.setChanged
		this.notifyObservers()
	}

	override testOk(String testName) {
		
		testByName(testName).endedOk()

		this.setChanged
		this.notifyObservers
	}
	
	override testsToRun(String suiteName, String containerResource, List<WollokTestInfo> tests, boolean processingManyFiles) {
		this.container = new WollokTestContainer
		this.container.suiteName = suiteName
		this.container.processingManyFiles = processingManyFiles
		this.container.mainResource = URI.createURI(containerResource)
		this.container.defineTests(newArrayList(tests.map[new WollokTestResult(it)]), this.shouldShowOnlyFailuresAndErrors)
		
		this.setChanged
		this.notifyObservers		
	}
	
	override showFailuresAndErrorsOnly(boolean showFailuresAndErrors) {
		this.shouldShowOnlyFailuresAndErrors = showFailuresAndErrors
		this.container.filterTestByState(this.shouldShowOnlyFailuresAndErrors)

		this.setChanged
		this.notifyObservers		
	}

	override testStart(String testName) {
		testByName(testName).started()

		this.setChanged
		this.notifyObservers
	}

	def testByName(String testName){
		this.container.testByName(testName)
	}
	
	override error(String testName, String exceptionAsString, StackTraceElementDTO[] stackTrace, int lineNumber, String resource) {
		testByName(testName).endedError(exceptionAsString, stackTrace, lineNumber, resource)
		
		this.setChanged
		this.notifyObservers		
	}
	
	
	override notifyObservers(Object arg) {
		RunInUI.runInUI[super.notifyObservers(arg)]
	}
	
	override testsResult(List<WollokResultTestDTO> tests) {
		tests.forEach [
			val test = testByName(testName)
			if (ok()) {
				test.endedOk()
			}
			if (failure()) {
				test.endedAssertError(message, stackTraceFiltered, errorLineNumber, resource)
			}
			if (error()) {
				test.endedError(message, stackTraceFiltered, errorLineNumber, resource)
			}
		]
		this.container.filterTestByState(this.shouldShowOnlyFailuresAndErrors)
		this.setChanged
		this.notifyObservers
	}

}