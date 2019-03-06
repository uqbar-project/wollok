package org.uqbar.project.wollok.validation.rules

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WIfExpression

import static org.uqbar.project.wollok.Messages.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

class DontCompareEqualityOfWKORule {
	def static validate(WollokDslValidator reporter, WBinaryOperation it) {
		if(isEqualityComparison && isBinaryOperationInsideIfCondition &&
			(leftOperand.isWellKnownObject || rightOperand.notNullAnd[isWellKnownObject])) {

			reporter.reportEObject(WollokDslValidator_DO_NOT_COMPARE_FOR_EQUALITY_WKO, it,
				DontCompareEqualityOfWKORule.simpleName)
		}
	}

	def static dispatch boolean isBinaryOperationInsideIfCondition(EObject unused) { false }
	def static dispatch boolean isBinaryOperationInsideIfCondition(WBinaryOperation expression) {
		isBinaryOperationInsideIfCondition(expression, expression.eContainer)
	}

	def static dispatch isBinaryOperationInsideIfCondition(WBinaryOperation expression, EObject unused) { false }

	def static dispatch isBinaryOperationInsideIfCondition(WBinaryOperation expression, WBinaryOperation container) {
		isBinaryOperationInsideIfCondition(container)
	}

	def static dispatch isBinaryOperationInsideIfCondition(WBinaryOperation expression, WIfExpression container) {
		expression == container.condition
	}
}
