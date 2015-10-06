package org.uqbar.project.wollok.refactoring

import org.eclipse.xtext.xbase.compiler.ISourceAppender

/**
 * Provides a set of utility extension methods to make it easier to implement refactors
 * 
 * @author jfernandes
 */
class RefactoringExtensions {
	
	def static operator_doubleLessThan(ISourceAppender appender, String appendable) {
		appender.append(appendable)
		appender
	}
	
	
	
}