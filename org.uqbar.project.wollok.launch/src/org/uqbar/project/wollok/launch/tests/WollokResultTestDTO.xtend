package org.uqbar.project.wollok.launch.tests

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors
import wollok.lib.AssertionException

@Accessors
class WollokResultTestDTO implements Serializable {
	
	String testName
	String exceptionAsString
	int errorLineNumber
	String resource
	AssertionException assertionException
	
	def boolean ok() {
		assertionException == null && errorLineNumber == 0	
	}
	
	def boolean failure() {
		assertionException != null
	}
	
	def boolean error() {
		exceptionAsString != null && !exceptionAsString.empty
	}
	
	static def WollokResultTestDTO ok(String _testName) {
		return new WollokResultTestDTO => [
			testName = _testName
		]
	}
	
	static def WollokResultTestDTO assertionError(String _testName, AssertionException _assertionException, int _lineNumber, String _resource) {
		return new WollokResultTestDTO => [
			testName = _testName
			assertionException = _assertionException
			errorLineNumber = _lineNumber
			resource = _resource
		]
	}
	
	static def WollokResultTestDTO error(String _testName, String _exceptionAsString, int _lineNumber, String _resource) {
		return new WollokResultTestDTO => [
			testName = _testName
			exceptionAsString = _exceptionAsString
			errorLineNumber = _lineNumber
			resource = _resource
		]
	}
	
}