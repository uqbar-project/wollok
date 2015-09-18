package org.uqbar.project.wollok.ui.tests.model

import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.tests.WollokTestInfo
import wollok.lib.AssertionException

@Accessors
class WollokTestResult {
	val WollokTestInfo testInfo
	var WollokTestState state
	var long startTime = 0;
	var long endTime = 0;
	var URI testResource
	var URI errorResource
	int lineNumber
	Exception exception

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
	
	def endedAssertError(AssertionException exception, int lineNumber, String resource) {
		endTime = System.currentTimeMillis
		state = WollokTestState.ASSERT
		this.exception = exception
		this.lineNumber = lineNumber
		this.errorResource = URI.createURI(resource)
	}
	
	def endedError(Exception exception, int lineNumber, String resource) {
		endTime = System.currentTimeMillis
		state = WollokTestState.ERROR
		this.errorResource = URI.createURI(resource)
		this.lineNumber = lineNumber
		this.exception = exception;
	}
	
	def getAssertException(){
		exception as AssertionException
	}
	
	override toString() {
		"Test: " + testResource.toString + " State: " + state
	}
	
}
