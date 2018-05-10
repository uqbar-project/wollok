package org.uqbar.project.wollok.typesystem.constraints

import java.util.List

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach

class OverridingConstraintsGenerator {
	extension TypeVariablesRegistry registry
	List<WMethodDeclaration> overridingMethods = newArrayList
	
	
	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def addMethodOverride(WMethodDeclaration declaration) {
		overridingMethods.add(declaration)
	}

	def run() {
		overridingMethods.forEach[
			val superClass = declaringContext.parent
			val superMethod = registry.methodTypes.forClass(superClass, name, parameters)
			superMethod.returnType.beSupertypeOf(tvar)
			superMethod.parameters.biForEach(parameters)[superParam, myParam|
				superParam.beSubtypeOf(myParam.tvar)
			]
		]
	}
}
