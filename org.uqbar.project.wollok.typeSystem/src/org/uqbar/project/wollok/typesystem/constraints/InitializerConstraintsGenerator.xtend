package org.uqbar.project.wollok.typesystem.constraints

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WInitializer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

class InitializerConstraintsGenerator extends CrossReferenceConstraintsGenerator<WInitializer> {

	new(TypeVariablesRegistry registry) {
		super(registry)
	}

	override generate(WInitializer it) {
		initializedVariable.variable.tvarOrParam.instanceFor(context.tvar).beSupertypeOf(initialValue.tvar)
	}
	
	def initializedVariable(WInitializer it) {
		val instantiatedClass = declaringConstructorCall?.classRef ?: declaringContext.parent
		instantiatedClass.getVariableDeclaration(initializer.name)
	}
	
	def context(WInitializer it) {
		// Initializer could be in a ConstructorCall or an object parent declaration
		declaringConstructorCall ?: declaringContext
	}

}
