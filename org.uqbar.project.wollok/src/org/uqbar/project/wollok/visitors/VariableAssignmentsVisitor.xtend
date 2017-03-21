package org.uqbar.project.wollok.visitors

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.WollokConstants.*

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
		if (e != null) {
			visit(e)
			println("visiting " + e)
		}
	}	

	def static assignmentOf(WVariable lookedFor, EObject container) {
		(new VariableAssignmentsVisitor => [
			it.lookedFor = lookedFor
			doVisit(container)
		]).uses
	}
	
	// potatoe: specific methods to detect assignments

	override dispatch visit(WVariableDeclaration it) {
		println("VD") 
		addIf[ variable == lookedFor && right != null ]
	}
	override dispatch visit(WAssignment it) {
		println("WA") 
		addIf[feature.ref == lookedFor]
	}
	override dispatch visit(WPostfixOperation it) {
		println("PFO") 
		addIf[ operand.isReferenceTo(lookedFor) ]
	}
	override dispatch visit(WBinaryOperation it) {
		println("BO") 
		addIf[ isMultiOpAssignment && leftOperand.isReferenceTo(lookedFor) ]
	}
	// helpers
	
	protected def <T extends EObject> addIf(T it, (T)=>Boolean condition) {
		if (condition.apply(it))
			uses.add(it)
	}
	
	def static isReferenceTo(WExpression it, WVariable variable) {
		it instanceof WVariableReference && (it as WVariableReference).ref == variable
	}
	
	// I'm not sure if this is a hack
	//  why visiting the content of the reference ?
	//  in a WKO referencing itself was introducing a stackoverflow
	override dispatch void visit(WVariableReference it) {
		println("VR") 
		// does nothing ! 
	}
	
}
