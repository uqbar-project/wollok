package org.uqbar.project.wollok.typesystem.constraints

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.ConstraintGenerator.*

class SuperInvocationConstraintsGenerator extends CrossReferenceConstraintsGenerator<WSuperInvocation> {

	new(TypeVariablesRegistry registry) {
		super(registry)
	}

	override generate(WSuperInvocation it) {
		linkReturnType
		linkParameterTypes
	}

	def linkReturnType(WSuperInvocation it) {
		if (superMethod.hasReturnType)
			superMethod.tvar.beSubtypeOf(tvar)
	}

	def linkParameterTypes(WSuperInvocation it) {
		superMethod.parameters.beAllSupertypeOf(memberCallArguments)
	}

}
