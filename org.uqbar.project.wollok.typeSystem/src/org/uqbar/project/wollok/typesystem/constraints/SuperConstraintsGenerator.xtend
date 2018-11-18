package org.uqbar.project.wollok.typesystem.constraints

import java.util.List
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach

class SuperConstraintsGenerator {
	extension TypeVariablesRegistry registry
	List<WSuperInvocation> superInvocations = newArrayList
	
	
	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def addSuperInvocation(WSuperInvocation invocation) {
		superInvocations.add(invocation)
	}

	def run() {
		superInvocations.forEach[
			superMethod.tvar.beSupertypeOf(newTypeVariable)
			superMethod.parameters.biForEach(memberCallArguments)[superParam, myParam|
				superParam.tvar.beSubtypeOf(myParam.tvar)
			]
		]
	}
}


		