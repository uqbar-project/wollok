package org.uqbar.project.wollok.visitors

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WVariable
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.declarationContext

/**
 * This visitor get all the uses of the lookedFor variable
 * 
 * @author tesonep
 * @author npasserini
 */
@Accessors
class VariableUsesVisitor extends AbstractWollokVisitor {
	List<EObject> uses = newArrayList
	WVariable lookedFor

	// ************************************************************************
	// ** Visiting
	// ************************************************************************

	override dispatch visit(WAssignment asg) {
		if (asg.feature.ref == lookedFor)
			uses.add(asg)
		asg.value.doVisit
	}

	override dispatch visit(WVariableReference ref) {
		if (ref.ref == lookedFor)
			uses.add(ref.eContainer)
	}

	override dispatch visit(WInitializer i) {
		if (i.initializer.name == lookedFor)
			uses.add(i)
	}

	// ************************************************************************
	// ** Utilities
	// ************************************************************************

	def static usesOf(WVariable lookedFor) {
		usesOf(lookedFor, lookedFor.declarationContext)
	}
	
	def static usesOf(WVariable lookedFor, EObject container) {
		val visitor = new VariableUsesVisitor
		visitor.lookedFor = lookedFor
		visitor.visit(container)
		visitor.uses
	}
}
