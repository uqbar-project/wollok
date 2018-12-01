package org.uqbar.project.wollok.typesystem.constraints

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WDelegatingConstructorCall

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class DelegatingConstructorCallConstraintsGenerator extends CrossReferenceConstraintsGenerator<WDelegatingConstructorCall> {

	new(TypeVariablesRegistry registry) {
		super(registry)
	}

	override generate(WDelegatingConstructorCall it) {
		declaringContext.resolveConstructorReference(it).parameters.beAllSupertypeOf(arguments)
	}
}
