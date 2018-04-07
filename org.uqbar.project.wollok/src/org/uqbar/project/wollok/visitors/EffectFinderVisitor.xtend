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

import static extension java.lang.Math.max

/**
 * This visitor to find effects in an expression tree
 * 	
 * @author npasserini
 */
class EffectFinderVisitor extends AbstractVisitor {
	public static val PURE = 0
	public static val SHOULD_BE_PURE = 1
	public static val UNKNOWN = 2
	public static val EFFECTFUL = 3 
	
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
		purity = SHOULD_BE_PURE
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
	
	static def isPure(WExpression expression, int acceptedPurity) {
		val visitor = new EffectFinderVisitor(acceptedPurity)
		visitor.visit(expression)
		return visitor._purity <= acceptedPurity
	}
}
