package org.uqbar.project.wollok.ui.tests.model

import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.tests.WollokTestInfo

@Accessors
class WollokTestResult {
	val WollokTestInfo testInfo
	var WollokTestState state
	var long startTime = 0;
	var long endTime = 0;
	var URI testResource
	var URI errorResource
	int lineNumber
	String actual
	String expected
	String message

	new(WollokTestInfo testInfo) {
		this.testInfo = testInfo
		state = WollokTestState.PENDING
		testResource = URI.createURI(testInfo.resource)
	}

	def getName() {
		testInfo.name
	}

	def void endedOk(){
		endTime = System.currentTimeMillis
		state = WollokTestState.OK
	}
	
	def void started(){
		state = WollokTestState.RUNNING
		startTime = System.currentTimeMillis
	}
	
	def endedAssertError(String message, String expected, String actual, int lineNumber, String resource) {
		endTime = System.currentTimeMillis
		state = WollokTestState.ASSERT
		this.message = message
		this.expected = expected
		this.actual = actual
		this.lineNumber = lineNumber
		this.errorResource = URI.createURI(resource)
	}
	
	def endedError(String message, int lineNumber, String resource) {
		endTime = System.currentTimeMillis
		state = WollokTestState.ERROR
		this.errorResource = URI.createURI(resource)
		this.lineNumber = lineNumber
		this.message = message;
	}
	
	override toString() {
		"Test: " + testResource.toString + " State: " + state
	}
	
}
