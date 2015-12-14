package org.uqbar.project.wollok.launch.repl

import org.eclipse.xtext.validation.Issue

/**
 * @author tesonep
 */
class ReplParserException extends RuntimeException {
	val Iterable<Issue> issues
	
	new(Iterable<Issue> issues) {
		this.issues = issues
	}
	
	def getIssues() {
		issues
	}
}