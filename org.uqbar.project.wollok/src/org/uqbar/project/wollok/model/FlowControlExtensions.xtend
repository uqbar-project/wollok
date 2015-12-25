package org.uqbar.project.wollok.model

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WBlock
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry

/**
 * @author jfernandes
 */
class FlowControlExtensions {
	// TODO: I think there are duplicate logic in WollokModelExtensions.returnsOnAllPossibleFlows
	
	def static dispatch boolean cutsTheFlow(WTry it) { expression.cutsTheFlow && !catchBlocks.empty && catchBlocks.forall[cutsTheFlow] }
	def static dispatch boolean cutsTheFlow(WBlock it) { expressions != null && expressions.last.cutsTheFlow }
	def static dispatch boolean cutsTheFlow(WReturnExpression it) { true }
	def static dispatch boolean cutsTheFlow(WThrow it) { true }
	def static dispatch boolean cutsTheFlow(WCatch it) { expression.cutsTheFlow }
	def static dispatch boolean cutsTheFlow(EObject it) { false }
	
}