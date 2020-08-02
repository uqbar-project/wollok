package org.uqbar.project.wollok.tests.debugger.util

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class DebugAsserter {
	List<String> expectedSteps
	String program
	
	def setExpect(java.util.List<String> steps) {
		this.expectedSteps = steps
	}
	
}
	
