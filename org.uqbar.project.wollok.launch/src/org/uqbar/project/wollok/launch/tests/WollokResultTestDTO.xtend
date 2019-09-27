package org.uqbar.project.wollok.launch.tests

import java.io.Serializable
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.errorHandling.StackTraceElementDTO

@Accessors
class WollokResultTestDTO implements Serializable {
	
	String testName
	String suiteName
	String file
	int errorLineNumber
	String resource
	String message
	StackTraceElementDTO[] stackTrace
	boolean error = false
	long totalTime
	
	def boolean ok() {
		message === null && errorLineNumber == 0	
	}
	
	def boolean failure() {
		!ok && !error
	}
	
	def boolean error() {
		!ok && error
	}
	
	static def WollokResultTestDTO ok(String _file, String _suiteName, String _testName) {
		return new WollokResultTestDTO => [
			file = _file
			suiteName = _suiteName
			testName = _testName
		]
	}
	
	static def WollokResultTestDTO assertionError(String _file, String _suiteName, String _testName, String _message, List<StackTraceElementDTO> _stackTrace, int _lineNumber, String _resource) {
		return new WollokResultTestDTO => [
			file = _file
			suiteName = _suiteName
			testName = _testName
			message = _message
			stackTrace = _stackTrace
			errorLineNumber = _lineNumber
			resource = _resource
		]
	}
	
	static def WollokResultTestDTO error(String _file, String _suiteName, String _testName, String _message, List<StackTraceElementDTO> _stackTrace, int _lineNumber, String _resource) {
		return new WollokResultTestDTO => [
			file = _file
			suiteName = _suiteName
			testName = _testName
			message = _message	
			stackTrace = _stackTrace
			errorLineNumber = _lineNumber
			resource = _resource
			error = true
		]
	}
	
}
