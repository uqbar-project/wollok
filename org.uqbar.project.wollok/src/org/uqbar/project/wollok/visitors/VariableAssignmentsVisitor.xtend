package org.uqbar.project.wollok.visitors

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WExpression

/**
 * This visitor get all the assignments of the lookedFor variable
 * @author	tesonep
 * @author jfernandes
 */
class VariableAssignmentsVisitor extends AbstractVisitor {
	@Accessors
	List<EObject> uses = newArrayList
	@Accessors
	WVariable lookedFor
	
	// generic visitor methods
	
	override doVisit(EObject e) {
		if (e != null)
			visit(e)
	}	

	def static assignmentOf(WVariable lookedFor, EObject container) {
		(new VariableAssignmentsVisitor => [
			it.lookedFor = lookedFor
			doVisit(container)
		]).uses
	}
	
	// potatoe: specific methods to detect assignments

	override dispatch visit(WVariableDeclaration it) { addIf[ variable == lookedFor && right != null ] }
	override dispatch visit(WAssignment it) { addIf[feature.ref == lookedFor] }
	override dispatch visit(WPostfixOperation it) { addIf[ operand.isReferenceTo(lookedFor) ] }
	
	// helpers
	
	protected def <T extends EObject> addIf(T it, (T)=>Boolean condition) {
		if (condition.apply(it))
			uses.add(it)
	}
	
	def static isReferenceTo(WExpression it, WVariable variable) {
		it instanceof WVariableReference && (it as WVariableReference).ref == variable
	}

}
