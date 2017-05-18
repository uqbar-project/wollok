package org.uqbar.project.wollok.ui.tests.model

import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.tests.StackTraceElementDTO
import org.uqbar.project.wollok.launch.tests.WollokTestInfo

/**
 * Test result model for the UI.
 * Gets populated by the event raised by the wollok launcher that gets to the UI via RMI.
 * 
 * @author tesonep
 */
@Accessors
class WollokTestResult {
	val WollokTestInfo testInfo
	var WollokTestState state
	var long startTime = 0
	var long endTime = 0
	var URI testResource
	var URI errorResource
	int lineNumber
	// for other exceptions we just get the string. This is a hack, but I need to cut the refactor (exceptions to wollok)
	String exceptionAsString
	String mainResource

	new(WollokTestInfo testInfo) {
		this.testInfo = testInfo
		state = WollokTestState.PENDING
		testResource = URI.createURI(testInfo.resource)
		mainResource = testInfo.resource //testInfo.fileURI
	}

	def getName() {
		testInfo.name
	}

	def void endedOk(){
		ended(WollokTestState.OK)
	}
	
	def void started() {
		state = WollokTestState.RUNNING
		startTime = System.currentTimeMillis
	}
	
	def endedAssertError(String message, StackTraceElementDTO[] stackTrace, int lineNumber, String resource) {
		innerEnded(lineNumber, resource, WollokTestState.ASSERT)
		this.exceptionAsString = message + System.lineSeparator + stackTrace.printStackTrace
	}
	
	def endedError(String exceptionAsString, StackTraceElementDTO[] stackTrace, int lineNumber, String resource) {
		innerEnded(lineNumber, resource, WollokTestState.ERROR)
		this.exceptionAsString = exceptionAsString + System.lineSeparator + stackTrace.printStackTrace
	}
	
	def innerEnded(int lineNumber, String resource, WollokTestState state) {
		ended(state)
		this.lineNumber = lineNumber
		if (resource != null)
			this.errorResource = URI.createURI(resource)
	}
	
	def ended(WollokTestState state) {
		this.state = state 
		endTime = System.currentTimeMillis
	}
	
	override toString() {
		"Test: " + testResource.toString + " State: " + state
	}
	
	def getErrorOutput() {
		exceptionAsString
	}

	def printStackTrace(StackTraceElementDTO[] stackTrace) {
		stackTrace.reverse.fold("", [ acum, ste | acum + ste.toLink(testResource)  ])
	}
	
	def failed() {
		#[WollokTestState.ASSERT, WollokTestState.ERROR].contains(state)		
	}
	
}
