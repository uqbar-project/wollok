package org.uqbar.project.wollok.visitors

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

/**
 * This visitor get all the assignments of the lookedFor variable
 * @author	tesonep
 */
class VariableAssignmentsVisitor extends AbstractVisitor {
	@Property
	List<EObject> uses = newArrayList
	@Property
	WVariable lookedFor

	override dispatch visit(WVariableDeclaration decl) {
		if (decl.variable == lookedFor && decl.right != null)
			uses.add(decl)
	}

	override dispatch visit(WAssignment assign) {
		if (assign.feature.ref == lookedFor)
			uses.add(assign)
	}

	override doVisit(EObject e) {
		if (e != null)
			visit(e)
	}	

	def static assignmentOf(WVariable lookedFor, EObject container) {
		val visitor = new VariableAssignmentsVisitor
		visitor.lookedFor = lookedFor
		visitor.doVisit(container)
		visitor.uses
	}
}
