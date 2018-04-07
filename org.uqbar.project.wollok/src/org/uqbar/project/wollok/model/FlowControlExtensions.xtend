package org.uqbar.project.wollok.model

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry

/**
 * @author jfernandes
 */
class FlowControlExtensions {
	// TODO: I think there are duplicate logic in WollokModelExtensions.returnsOnAllPossibleFlows
	// TODO 2: Move returnsOnAllPossibleFlows and similar methods here
	
	def static dispatch boolean cutsTheFlow(WTry it) { expression !== null && expression.cutsTheFlow && !catchBlocks.empty && catchBlocks.forall[cutsTheFlow] }
	def static dispatch boolean cutsTheFlow(WBlockExpression it) {
		val lastExpression = expressions.last  
		lastExpression !== null && lastExpression.cutsTheFlow
	}
	def static dispatch boolean cutsTheFlow(WReturnExpression it) { true }
	def static dispatch boolean cutsTheFlow(WThrow it) { true }
	def static dispatch boolean cutsTheFlow(WCatch it) { expression !== null && expression.cutsTheFlow }
	def static dispatch boolean cutsTheFlow(EObject it) { false }
	
	def static dispatch boolean shouldGetDeeperInStack(EObject o) { false }
	def static dispatch boolean shouldGetDeeperInStack(WExpression e) { true }

}