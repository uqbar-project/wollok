package org.uqbar.project.wollok.typesystem.constraints

import java.util.List
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
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
			val superMethod = registry.methodTypeInfo(superClass, name, parameters)
			tvar.beSubtypeOf(superMethod.returnType)
			parameters.biForEach(superMethod.parameters)[myParam, superParam|
				myParam.tvar.beSupertypeOf(superParam)
			]
		]
	}
}