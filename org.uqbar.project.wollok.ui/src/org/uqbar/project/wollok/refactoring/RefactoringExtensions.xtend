package org.uqbar.project.wollok.refactoring

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.util.TextRegion
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
	
	def static getRegion(org.eclipse.xtext.xbase.ui.refactoring.ExpressionUtil expressionUtil, EObject firstExpression, EObject lastExpression) {
		val firstRegion = expressionUtil.getTextRegion(firstExpression)
		val lastRegion = expressionUtil.getTextRegion(lastExpression)
		new TextRegion(firstRegion.offset, lastRegion.offset + lastRegion.length - firstRegion.offset)
	}
	
	
}