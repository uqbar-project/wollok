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

	def dispatch beforeVisit(WAssignment it) {
		if (feature.ref == lookedFor) uses.add(it)
	}

	def dispatch beforeVisit(WVariableReference it) {
		if (ref == lookedFor) uses.add(eContainer)
	}

	def dispatch beforeVisit(WInitializer it) {
		if (initializer === lookedFor) uses.add(it)
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
