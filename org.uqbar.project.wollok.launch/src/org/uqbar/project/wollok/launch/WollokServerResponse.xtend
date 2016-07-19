package org.uqbar.project.wollok.launch

import org.eclipse.xtend.lib.annotations.Accessors

/**
 * This class is created to hold the data received in a response from the wollok server, 
 * so its attributes mimic the structure of the json object.
 *  
 * @author npasserini
 */
@Accessors
class WollokServerResponse {
	String wollokVersion
	String consoleOutput
	CompilationInfo compilation
	TestResult[] tests
	RuntimeError runtimeError
	
	@Accessors
	static class CompilationInfo {
		CompilationResult result
		CompilationIssue[] issues 
	}

	/**
	 * This object mimics the structure of a xtext issue: org.eclipse.xtext.validation.
	 * There are more fields that have been ignored by now because they didn't seem interesting, 
	 * but they could be added if needed.
	 */	
	@Accessors
	static class CompilationIssue {
		String severity
		String code
		String message
		String uri
		int lineNumber
		int offset
		int length
		boolean syntaxError
	}
	
	@Accessors 
	static class TestInfo{
		TestResult result
		String name
		String errorMessage
		String[] stackTrace
	}

	@Accessors 
	static class RuntimeError {
		String message
		StackTraceElement[] stackTrace
	}

	@Accessors
	static class StackTraceElement {
		String contextDescription
		String location	
	}
	
	enum CompilationResult { PASSED, FAILED }
	enum TestResult { PASSED, FAILED }
}