package org.uqbar.project.wollok.typesystem.constraints

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WConstructorCall

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.resolveConstructor
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

/**
 * @author npasserini
 */
class ConstructorConstraintsGenerator extends CrossReferenceConstraintsGenerator<WConstructorCall> {

	new(TypeVariablesRegistry registry) {
		super(registry)
	}

	override generate(WConstructorCall it) {
		val constructor = classRef.resolveConstructor(values)

		// Constructor might be null when neither the referred class nor any of it superclasses define a constructor,
		// And wouldn't be an error if the constructor call has no parameters.
		// TODO Handle and inform error conditions.
		// TODO 2: We should consider also argumentList.initializers
		constructor?.parameters?.biForEach(values) [ param, arg |
			param.tvarOrParam.instanceFor(it.tvar).beSupertypeOf(arg.tvar)
		]
	}

}
