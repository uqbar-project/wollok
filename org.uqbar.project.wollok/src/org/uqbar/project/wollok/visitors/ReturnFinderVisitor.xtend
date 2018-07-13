package org.uqbar.project.wollok.visitors

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WReturnExpression

/**
 * This visitor finds all return expressions
 * @author npasserini
 */
class ReturnFinderVisitor extends AbstractWollokVisitor {
	@Accessors
	List<WReturnExpression> returnExpressions = newArrayList
	
	@Accessors
	boolean stopOnFirstFinding = false
	
	def returnsFound() { !returnExpressions.empty }
	
	override shouldContinue(EObject unused) { !returnsFound || !stopOnFirstFinding }
	
	override dispatch visit(WReturnExpression it) { returnExpressions += it }
	
	static def containsReturnExpression(WExpression expression) {
		(new ReturnFinderVisitor() => [
			stopOnFirstFinding = true
			visit(expression)
		]).returnsFound
	}
}
	