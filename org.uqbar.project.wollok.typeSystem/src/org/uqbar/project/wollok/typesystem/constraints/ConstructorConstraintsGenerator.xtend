package org.uqbar.project.wollok.typesystem.constraints

import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariablesRegistry
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * @author npasserini
 */
abstract class ConstructorConstraintsGenerator<T extends EObject> extends CrossReferenceConstraintsGenerator<T> {

	new(TypeVariablesRegistry registry) {
		super(registry)
	}
	
	def generate(EObject it, WClass clazz, EList<WInitializer> initializers) {
		// Wollok 3.0.0 removed constructor idea, so constructor is null
		// TODO: We should consider also argumentList.initializers
	}
}

class ConstructorCallConstraintsGenerator extends ConstructorConstraintsGenerator<WConstructorCall> {
	
	new(TypeVariablesRegistry registry) {
		super(registry)
	}
	
	override generate(WConstructorCall it) {
		generate(classRef, initializers)
	}
}

class ObjectParentConstraintsGenerator extends ConstructorConstraintsGenerator<WMethodContainer> {
	
	new(TypeVariablesRegistry registry) {
		super(registry)
	}
	
	override generate(WMethodContainer it) {
//		if (parent.hasParentParameters)
//			generate(parent, parent?.parentParameters)
//		else
		if (!parent.hasParentParameters)
			generate(parent)
	}
	
}