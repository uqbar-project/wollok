package org.uqbar.project.wollok.model

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WCollectionLiteral
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.services.WollokDslGrammarAccess.OpMultiAssignElements
import org.uqbar.project.wollok.WollokConstants

/**
 * Extension methods related to validating values
 * and expression.
 * 
 * @author jfernandes
 */
class WEvaluationExtension {
	
	def static boolean isUsedAsValue(WMemberFeatureCall call) { 
		call.eContainingFeature.evaluatesContent || (call.eContainer instanceof WMethodDeclaration && (call.eContainer as WMethodDeclaration).isExpressionReturns)
	}

	/**
	 * Tells whether the feature (an attribute of the semantic model)
	 * expects the content to be evaluted to a value.
	 * This is useful to check if the actual content produces a value.
	 */
	def static boolean isEvaluatesContent(EStructuralFeature it) {
		it == WASSIGNMENT__VALUE
		|| it == WVARIABLE_DECLARATION__RIGHT
		|| it == WIF_EXPRESSION__CONDITION
		|| it == WRETURN_EXPRESSION__EXPRESSION
		|| it == WMEMBER_FEATURE_CALL__MEMBER_CALL_TARGET
		|| it == WMEMBER_FEATURE_CALL__MEMBER_CALL_ARGUMENTS
		// binary ops
		|| it == WBINARY_OPERATION__LEFT_OPERAND
		|| it == WBINARY_OPERATION__RIGHT_OPERAND
		// collections literals
		|| it == WCOLLECTION_LITERAL__ELEMENTS
		|| it == WSUPER_INVOCATION__MEMBER_CALL_ARGUMENTS
		|| it == WCONSTRUCTOR_CALL__ARGUMENTS
		|| it == WTHROW__EXCEPTION
	}
	
	// literals
	def static dispatch boolean isEvaluatesToAValue(WCollectionLiteral it) { true }
	def static dispatch boolean isEvaluatesToAValue(WNumberLiteral it) { true }
	def static dispatch boolean isEvaluatesToAValue(WStringLiteral it) { true }
	def static dispatch boolean isEvaluatesToAValue(WObjectLiteral it) { true }
	def static dispatch boolean isEvaluatesToAValue(WNullLiteral it) { true }
	def static dispatch boolean isEvaluatesToAValue(WBooleanLiteral it) { true }
	def static dispatch boolean isEvaluatesToAValue(WSelf it) { true }
	def static dispatch boolean isEvaluatesToAValue(WClosure it) { true }
	def static dispatch boolean isEvaluatesToAValue(WVariableReference it) { true }
	// ops
	def static dispatch boolean isEvaluatesToAValue(WBinaryOperation it) { !WollokConstants.OPMULTIASSIGN.contains(feature) }
	def static dispatch boolean isEvaluatesToAValue(WConstructorCall it) { true }
	def static dispatch boolean isEvaluatesToAValue(WUnaryOperation it) { true }
	def static dispatch boolean isEvaluatesToAValue(WPostfixOperation it) { true }
	// constructions
	def static dispatch boolean isEvaluatesToAValue(WReturnExpression it) { true }
	def static dispatch boolean isEvaluatesToAValue(WIfExpression it) { then.evaluatesToAValue && (^else == null || ^else.evaluatesToAValue) }
	def static dispatch boolean isEvaluatesToAValue(WBlockExpression it) { expressions.last.evaluatesToAValue }
	def static dispatch boolean isEvaluatesToAValue(WTry it) { expression.evaluatesToAValue && catchBlocks.forall[c| c.expression.evaluatesToAValue ] }
	// calls
	def static dispatch boolean isEvaluatesToAValue(WSuperInvocation it) { method.overridenMethod != null && method.overridenMethod.returnsValue }
	def static dispatch boolean isEvaluatesToAValue(WMemberFeatureCall it) { val m = resolveMethod ; m != null && m.returnsValue }
	// default
	def static dispatch boolean isEvaluatesToAValue(Void it) { false }
	def static dispatch boolean isEvaluatesToAValue(EObject it) { false }
}