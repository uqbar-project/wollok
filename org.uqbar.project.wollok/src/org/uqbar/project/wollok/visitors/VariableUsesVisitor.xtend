package org.uqbar.project.wollok.visitors

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableReference

/**
 * This visitor get all the uses of the lookedFor variable
 * 
 * @author tesonep
 */
class VariableUsesVisitor extends AbstractVisitor {
	@Property
	List<EObject> uses = newArrayList
	@Property
	WVariable lookedFor

	override dispatch visit(WAssignment asg) {
		if (asg.feature.ref == lookedFor)
			uses.add(asg)
		asg.value.doVisit
	}

	override dispatch visit(WVariableReference ref) {
		if (ref.ref == lookedFor)
			uses.add(ref.eContainer)
	}

	def static usesOf(WVariable lookedFor, EObject container) {
		val visitor = new VariableUsesVisitor
		visitor.lookedFor = lookedFor
		visitor.visit(container)
		visitor.uses
	}
}
