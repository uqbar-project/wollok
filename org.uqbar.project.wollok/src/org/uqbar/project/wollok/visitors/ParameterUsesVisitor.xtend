package org.uqbar.project.wollok.visitors

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.uqbar.project.wollok.wollokDsl.WVariableReference

class ParameterUsesVisitor extends AbstractWollokVisitor {

	List<EObject> uses = newArrayList
	WParameter lookedFor

	override dispatch visit(WVariableReference ref) {
		if (ref.ref == lookedFor)
			uses.add(ref.eContainer)
	}

	override dispatch visit(WConstructor constructor) {
		if (constructor.parameters.contains(lookedFor))
			uses.add(constructor)
	}

	def static usesOf(WParameter lookedFor, EObject container) {
		val visitor = new ParameterUsesVisitor
		visitor.lookedFor = lookedFor
		visitor.visit(container)
		visitor.uses
	}
	
}