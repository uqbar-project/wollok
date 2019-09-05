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
	var WollokTestFileContainer fileContainer = new WollokTestFileContainer
	
	@Accessors
	var WollokTestGlobalContainer globalContainer = new WollokTestGlobalContainer
	
	override start(){
		globalContainer = new WollokTestGlobalContainer
	}
	
	override startFile(String file) {
		fileContainer = new WollokTestFileContainer
		fileContainer.mainResource = URI.createURI(file)
	}
	
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
		val container = new WollokTestContainer
		container.suiteName = suiteName
		container.processingManyFiles = processingManyFiles
		container.mainResource = URI.createURI(containerResource)
		container.defineTests(newArrayList(tests.map[new WollokTestResult(it)]), this.shouldShowOnlyFailuresAndErrors)
		
		fileContainer.processingManyFiles = processingManyFiles
		fileContainer.add(container)
		globalContainer.add(this.fileContainer)
		globalContainer.processingManyFiles = processingManyFiles
		
		this.setChanged
		this.notifyObservers("testReceived")		
	}
	
	override showFailuresAndErrorsOnly(boolean showFailuresAndErrors) {
		this.shouldShowOnlyFailuresAndErrors = showFailuresAndErrors
		this.fileContainer.filterTestByState(this.shouldShowOnlyFailuresAndErrors)

		this.setChanged
		this.notifyObservers("testsEnded")		
	}

	override testStart(String testName) {
		testByName(testName).started()

		this.setChanged
		this.notifyObservers
	}

	def testByName(String testName){
		globalContainer.testByName(testName)
	}
	
	override error(String testName, String exceptionAsString, StackTraceElementDTO[] stackTrace, int lineNumber, String resource) {
		testByName(testName).endedError(exceptionAsString, stackTrace, lineNumber, resource)
		
		this.setChanged
		this.notifyObservers		
	}
	
	
	override notifyObservers(Object arg) {
		RunInUI.runInUI[super.notifyObservers(arg)]
	}
	
	override testsResult(List<WollokResultTestDTO> tests, long millisecondsElapsed) {
		tests.forEach [
			val test = testByName(testName)
			if (ok()) {
				test.endedOk()
			}
			if (failure()) {
				test.endedAssertError(message, stackTrace, errorLineNumber, resource)
			}
			if (error()) {
				test.endedError(message, stackTrace, errorLineNumber, resource)
			}
		]		
		globalContainer.filterTestByState(this.shouldShowOnlyFailuresAndErrors)
		globalContainer.millisecondsElapsed = millisecondsElapsed
		this.setChanged
		this.notifyObservers
	}
	
	
	

}