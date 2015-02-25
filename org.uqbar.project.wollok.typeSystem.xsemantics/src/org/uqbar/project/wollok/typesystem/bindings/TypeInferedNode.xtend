package org.uqbar.project.wollok.typesystem.bindings

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.semantics.WollokType

/**
 * 
 * 
 * @author jfernandes
 */
class TypeInferedNode extends TypedNode {
	WollokType currentType
	
	new(EObject object, BoundsBasedTypeSystem s) {
		super(object, s)
	}
	
	override assignType(WollokType type) {
		currentType = type
		fireTypeChanged
	}
	
	override getType() { currentType }

	override toString() { '''InferredType(«if (type == null) "???" else type.name» <- «model.class.simpleName»)''' }	

}