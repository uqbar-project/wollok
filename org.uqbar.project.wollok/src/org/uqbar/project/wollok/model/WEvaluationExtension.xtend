package org.uqbar.project.wollok.model

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.WollokClassFinder
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
import org.uqbar.project.wollok.wollokDsl.WThis
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Extension methods related to validating values
 * and expression.
 * 
 * @author jfernandes
 */
class WEvaluationExtension {
	
	def static boolean isUsedAsValue(WMemberFeatureCall call, WollokClassFinder finder) { 
		call.eContainingFeature.isEvaluatesContent(finder) || (call.eContainer instanceof WMethodDeclaration && (call.eContainer as WMethodDeclaration).isExpressionReturns)
	}

	/**
	 * Tells whether the feature (an attribute of the semantic model)
	 * expects the content to be evaluted to a value.
	 * This is useful to check if the actual content produces a value.
	 */
	def static boolean isEvaluatesContent(EStructuralFeature it, WollokClassFinder finder) {
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
	def static dispatch boolean isEvaluatesToAValue(WCollectionLiteral it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WNumberLiteral it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WStringLiteral it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WObjectLiteral it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WNullLiteral it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WBooleanLiteral it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WThis it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WClosure it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WVariableReference it, WollokClassFinder finder) { true }
	// ops
	def static dispatch boolean isEvaluatesToAValue(WBinaryOperation it, WollokClassFinder finder) { !WollokConstants.OPMULTIASSIGN.contains(feature) }
	def static dispatch boolean isEvaluatesToAValue(WConstructorCall it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WUnaryOperation it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WPostfixOperation it, WollokClassFinder finder) { true }
	// constructions
	def static dispatch boolean isEvaluatesToAValue(WReturnExpression it, WollokClassFinder finder) { true }
	def static dispatch boolean isEvaluatesToAValue(WIfExpression it, WollokClassFinder finder) { then.isEvaluatesToAValue(finder) && (^else == null || ^else.isEvaluatesToAValue(finder)) }
	def static dispatch boolean isEvaluatesToAValue(WBlockExpression it, WollokClassFinder finder) { expressions.last.isEvaluatesToAValue(finder) }
	def static dispatch boolean isEvaluatesToAValue(WTry it, WollokClassFinder finder) { expression.isEvaluatesToAValue(finder) && catchBlocks.forall[c| c.expression.isEvaluatesToAValue(finder) ] }
	// calls
	def static dispatch boolean isEvaluatesToAValue(WSuperInvocation it, WollokClassFinder finder) { method.overridenMethod != null && method.overridenMethod.supposedToReturnValue }
	def static dispatch boolean isEvaluatesToAValue(WMemberFeatureCall it, WollokClassFinder finder) { val m = resolveMethod(finder) ; m != null && m.supposedToReturnValue }
	// default
	def static dispatch boolean isEvaluatesToAValue(Void it, WollokClassFinder finder) { false }
	def static dispatch boolean isEvaluatesToAValue(EObject it, WollokClassFinder finder) { false }
}