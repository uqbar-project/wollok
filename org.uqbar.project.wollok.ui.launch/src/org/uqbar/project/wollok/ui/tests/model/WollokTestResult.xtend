package org.uqbar.project.wollok.ui.tests.model

import java.io.PrintWriter
import java.io.StringWriter
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.tests.WollokTestInfo
import wollok.lib.AssertionException

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
	var long startTime = 0;
	var long endTime = 0;
	var URI testResource
	var URI errorResource
	int lineNumber
	// for the assert exception
	Exception exception
	// for other exceptions we just get the string. This is a hack, but I need to cut the refactor (exceptions to wollok)
	String exceptionAsString

	new(WollokTestInfo testInfo) {
		this.testInfo = testInfo
		state = WollokTestState.PENDING
		testResource = URI.createURI(testInfo.resource)
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
	
	def endedAssertError(AssertionException exception, int lineNumber, String resource) {
		innerEnded(exception, lineNumber, resource, WollokTestState.ASSERT)
	}
	
	def endedError(String exceptionAsString, int lineNumber, String resource) {
		innerEnded(null, lineNumber, resource, WollokTestState.ERROR)
		this.exceptionAsString = exceptionAsString
	}
	
	def innerEnded(Exception e, int lineNumber, String resource, WollokTestState state) {
		ended(state)
		this.exception = e
		this.lineNumber = lineNumber
		this.errorResource = URI.createURI(resource)
	}
	
	def ended(WollokTestState state) {
		this.state = state 
		endTime = System.currentTimeMillis
	}
	
	def getAssertException(){
		exception as AssertionException
	}
	
	override toString() {
		"Test: " + testResource.toString + " State: " + state
	}
	
	def getErrorOutput() {
		if (exception != null) {
			val sw = new StringWriter
			exception.printStackTrace(new PrintWriter(sw))
			sw.toString	
		}
		else {
			exceptionAsString
		}
	}
	
}
