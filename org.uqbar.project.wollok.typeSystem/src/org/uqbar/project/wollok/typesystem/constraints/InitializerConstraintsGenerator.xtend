package org.uqbar.project.wollok.typesystem.constraints

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WInitializer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

class InitializerConstraintsGenerator extends CrossReferenceConstraintsGenerator<WInitializer> {

	new(TypeVariablesRegistry registry) {
		super(registry)
	}

	override generate(WInitializer it) {
		// Initializer could be in a ConstructorCall or an object parent declaration
		val instantiatedClass = declaringConstructorCall?.classRef ?: declaringContext.parent
		val initializedVariable = instantiatedClass.getVariableDeclaration(initializer.name)

		initializedVariable.variable.tvar.beSupertypeOf(initialValue.tvar)
	}

}
