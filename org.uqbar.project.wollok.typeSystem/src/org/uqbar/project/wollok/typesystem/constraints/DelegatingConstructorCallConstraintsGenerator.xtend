package org.uqbar.project.wollok.typesystem.constraints

import java.util.List
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WDelegatingConstructorCall

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach

class DelegatingConstructorCallConstraintsGenerator {
	extension TypeVariablesRegistry registry
	List<WDelegatingConstructorCall> superInvocations = newArrayList

	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def add(WDelegatingConstructorCall invocation) {
		superInvocations.add(invocation)
	}

	def run() {
		superInvocations.forEach[linkParameterTypes]
	}

	def linkParameterTypes(WDelegatingConstructorCall it) {
		declaringContext.resolveConstructorReference(it).parameters.beAllSupertypeOf(arguments)
	}

	def beAllSupertypeOf(EList<? extends EObject> supertypes, EList<? extends EObject> subtypes) {
		supertypes.map[tvar].biForEach(subtypes.map[tvar]) [ supertype, subtype |
			supertype.beSupertypeOf(subtype)
		]
	}
}
