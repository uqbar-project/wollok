package org.uqbar.project.wollok.typesystem.constraints

import java.util.List
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WConstructorCall

import static extension org.uqbar.project.wollok.utils.XtendExtensions.biForEach
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.resolveConstructor

/**
 * @author npasserini
 */
class ConstructorConstraintsGenerator {
	extension TypeVariablesRegistry registry
	
	List<WConstructorCall> constructorCalls = newArrayList
	
	new(TypeVariablesRegistry registry) {
		this.registry = registry
	}

	def addConstructorCall(WConstructorCall call) {
		this.constructorCalls.add(call)
	}

	def run() {
		constructorCalls.forEach[
			val constructor = classRef.resolveConstructor(arguments)

			// Constructor might be null when neither the referred class nor any of it superclasses define a constructor,
			// And wouldn't be an error if the constructor call has no parameters.
			// TODO Handle and inform error conditions.
			constructor?.parameters?.biForEach(arguments)[param, arg|
				try {
					arg.tvar.beSubtypeOf(param.tvar)
				} catch (Exception e) {}
			]
		]
	}
}
