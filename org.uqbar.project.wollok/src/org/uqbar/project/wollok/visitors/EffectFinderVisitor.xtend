package org.uqbar.project.wollok.visitors

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WThrow

import static extension java.lang.Math.max
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.isMultiOpAssignment
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.hasNamedParameters
import org.uqbar.project.wollok.wollokDsl.WConstructorCall

/**
 * This visitor to find effects in an expression tree
 * 	
 * @author npasserini
 */
class EffectFinderVisitor extends AbstractVisitor {
	public static val PURE = 0
	public static val SHOULD_BE_PURE = 1
	
	/**
	 * This is designed for managing return and throw sentences. While they are not effects in the strict sense,
	 * they should be considered correct in a sequence, so they have to be handled specifically.
	 * 
	 * This might be a bit custom for the current usage of this visitor (detecting pure expressions in sequences).
	 * Other uses of the effect/purity might need to refine this further. 
	 */
	public static val ALTERS_FLOW = 2
	public static val UNKNOWN = 3
	public static val EFFECTFUL = 4 
	
	int _purity = PURE
	int acceptedPurity
	
	new(int acceptedPurity) { this.acceptedPurity = acceptedPurity }
	
	def setPurity(int purity) { 
		_purity = _purity.max(purity)
	}
	
	override shouldContinue(EObject unused) { _purity <= acceptedPurity }
	
	override dispatch visit(WAssignment it) { purity = EFFECTFUL }
	override dispatch visit(WPostfixOperation it) { purity = EFFECTFUL }
	override dispatch visit(WVariableDeclaration it) { purity = EFFECTFUL }
	
	override dispatch visit(WBinaryOperation it) { 
		purity = if (isMultiOpAssignment) EFFECTFUL else SHOULD_BE_PURE
		super._visit(it)
	}

	override dispatch visit(WConstructorCall it) {
		if (!hasNamedParameters) purity = SHOULD_BE_PURE
		super._visit(it)
	}

	override dispatch visit(WUnaryOperation it) { 
		purity = SHOULD_BE_PURE
		super._visit(it)
	}
	
	override dispatch visit(WMemberFeatureCall it) { 
		purity = UNKNOWN
		super._visit(it)
	}
	
	override dispatch visit(WSuperInvocation it) {
		purity = UNKNOWN
		super._visit(it)
	}

	override dispatch visit(WReturnExpression it) {
		purity = ALTERS_FLOW
		super._visit(it)
	}

	override dispatch visit(WThrow it) {
		purity = ALTERS_FLOW
		super._visit(it)
	}
	
	static def isPure(WExpression expression, int acceptedPurity) {
		val visitor = new EffectFinderVisitor(acceptedPurity)
		visitor.visit(expression)
		return visitor._purity <= acceptedPurity
	}
}
