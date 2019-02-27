package org.uqbar.project.wollok.typesystem.constraints

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.resolveConstructor
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

/**
 * @author npasserini
 */
abstract class ConstructorConstraintsGenerator<T extends EObject> extends CrossReferenceConstraintsGenerator<T> {

	new(TypeVariablesRegistry registry) {
		super(registry)
	}
	
	def generate(EObject it, WClass clazz, EList<WExpression> values) {
		val constructor = clazz.resolveConstructor(values)

		// Constructor might be null when neither the referred class nor any of it superclasses define a constructor,
		// And wouldn't be an error if the constructor call has no parameters.
		// TODO Handle and inform error conditions.
		// TODO 2: We should consider also argumentList.initializers
		constructor?.parameters?.biForEach(values) [ param, arg |
			param.tvarOrParam.instanceFor(it.tvar).beSupertypeOf(arg.tvar)
		]		
	}
}

class ConstructorCallConstraintsGenerator extends ConstructorConstraintsGenerator<WConstructorCall> {
	
	new(TypeVariablesRegistry registry) {
		super(registry)
	}
	
	override generate(WConstructorCall it) {
		generate(classRef, values)
	}
}

class ObjectParentConstraintsGenerator extends ConstructorConstraintsGenerator<WNamedObject> {
	
	new(TypeVariablesRegistry registry) {
		super(registry)
	}
	
	override generate(WNamedObject it) {
		generate(parent, parentParameters.values)
	}
	
}