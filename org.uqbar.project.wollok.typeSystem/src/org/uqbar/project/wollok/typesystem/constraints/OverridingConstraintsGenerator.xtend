package org.uqbar.project.wollok.typesystem.constraints

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class OverridingConstraintsGenerator extends CrossReferenceConstraintsGenerator<WMethodDeclaration> {

	new(TypeVariablesRegistry registry) {
		super(registry)
	}

	override generate(WMethodDeclaration it) {
		val superClass = declaringContext.parent
		val superMethod = registry.methodTypes.methodTypeSchema(superClass, name, parameters)
		superMethod.returnType.beSupertypeOf(tvar)
		superMethod.parameters.beAllSubtypeOf(parameters.map[tvar])
	}

}
